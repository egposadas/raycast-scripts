#!/usr/bin/env osascript -l JavaScript

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Toggle sidecar
// @raycast.mode inline

// Optional parameters:
// @raycast.icon 🖥️

// Documentation:
// @raycast.description Toggle sidecar

/**
 * -----------------------------------------------------------------------------
 * Activate Sidecar/Screen Mirroring from Control Center
 * -----------------------------------------------------------------------------
 *
 * Created on February 17, 2023 by Stephan Casas
 * Updated on May 18, 2023 by Stephan Casas
 *
 * Options:
 *   - TARGET_DEVICE_NAME
 *     - The name of the sidecar/screen mirroring device to toggle.
 *     - This should be exactly as it's written in screen mirroring menu.
 *     - Include any whitespace characters as given in the menu entry.
 *
 *
 * Notes:
 *   This script was tested on macOS 13 Ventura and may break with future OS
 *   updates.
 */

function run(_) {
    const TARGET_DEVICE_NAME = 'C3P0' // Change this to your target device name
    const $attr = Ref()
    const $windows = Ref()
    const $children = Ref()

    // Get the current Control Center PID.
    const pid =
        $.NSRunningApplication.runningApplicationsWithBundleIdentifier('com.apple.controlcenter').firstObject
            .processIdentifier

    // Get the Control Center application.
    const app = $.AXUIElementCreateApplication(pid)

    // Get the Control Center menubar extra children.
    $.AXUIElementCopyAttributeValue(app, 'AXChildren', $children)
    $.AXUIElementCopyAttributeValue($children[0].js[0], 'AXChildren', $children)

    // Locate the Control Center menubar extra (also has Clock, Users, etc.).
    const ccExtra = $children[0].js.find((child) => {
        $.AXUIElementCopyAttributeValue(child, 'AXIdentifier', $attr)
        return $attr[0].js == 'com.apple.menuextra.controlcenter'
    })

    // Open Control Center window and await draw.
    $.AXUIElementPerformAction(ccExtra, 'AXPress')
    if (
        !(() => {
            const timeout = new Date().getTime() + 2000
            while (true) {
                $.AXUIElementCopyAttributeValue(app, 'AXWindows', $windows)
                if (typeof $windows[0] == 'function' && ($windows[0].js.length ?? 0) > 0) {
                    return true
                }
                if (new Date().getTime() > timeout) {
                    return false
                }
                delay(0.1)
            }
        })()
    ) {
        return
    }

    // Get Control Center window children.
    $.AXUIElementCopyAttributeValue($windows[0].js[0], 'AXChildren', $children)

    // Locate the Control Center modules group.
    const modulesGroup = $children[0].js.find((child) => {
        $.AXUIElementCopyAttributeValue(child, 'AXRole', $attr)
        return $attr[0].js == 'AXGroup'
    })

    // Get the individual modules within the modules group.
    $.AXUIElementCopyAttributeValue(modulesGroup, 'AXChildren', $children)

    // Locate the screen-mirroring module.
    const screenMirroring = $children[0].js.find((child) => {
        $.AXUIElementCopyAttributeValue(child, 'AXIdentifier', $attr)
        return $attr[0].js == 'controlcenter-screen-mirroring'
    })

    // Activate the screen mirroring module and await draw.
    $.AXUIElementPerformAction(
        screenMirroring,
        // Wtf is this action name, Apple??
        'Name:show details\nTarget:0x0\nSelector:(null)'
    )
    if (
        !(() => {
            const timeout = new Date().getTime() + 2000
            while (true) {
                $.AXUIElementCopyAttributeValue(modulesGroup, 'AXChildren', $children)
                if (typeof $children[0] == 'function' && ($children[0].js.length ?? 0) > 0) {
                    return true
                }
                if (new Date().getTime() > timeout) {
                    return false
                }
                delay(0.1)
            }
        })()
    ) {
        return
    }

    // Get the scroll area containing the device mirroring options.
    const mirroringOptions = $children[0].js.find((child) => {
        $.AXUIElementCopyAttributeValue(child, 'AXRole', $attr)
        return $attr[0].js == 'AXScrollArea'
    })

    // Get all mirroring options.
    $.AXUIElementCopyAttributeValue(mirroringOptions, 'AXChildren', $children)

    // First, try to find the device checkbox directly (works for both connect and disconnect)
    console.log('Searching for device checkbox to toggle...')

    let deviceToggle = findTargetDevice($children[0].js)

    if (deviceToggle) {
        // Check if device is currently connected
        $.AXUIElementCopyAttributeValue(deviceToggle, 'AXValue', $attr)
        const currentValue = $attr[0] ? $attr[0].js : 0

        if (currentValue === 1) {
            console.log('Device is currently connected, disconnecting...')
        } else {
            console.log('Device is currently disconnected, connecting...')
        }

        $.AXUIElementPerformAction(deviceToggle, 'AXPress')
        console.log('Toggle action completed successfully')
        return 0
    }

    // Enhanced debugging function to explore UI hierarchy deeply
    function debugUIHierarchy(element, depth = 0, maxDepth = 4) {
        if (depth > maxDepth) return;

        const indent = '  '.repeat(depth);

        try {
            $.AXUIElementCopyAttributeValue(element, 'AXRole', $attr)
            const role = $attr[0] ? $attr[0].js : 'Unknown'
            console.log(`${indent}Role: ${role}`)

            // Get additional attributes for debugging
            if (role === 'AXCheckBox' || role === 'AXButton') {
                $.AXUIElementCopyAttributeValue(element, 'AXDescription', $attr)
                const description = $attr[0] ? $attr[0].js : 'No description'
                console.log(`${indent}  Description: "${description}"`)

                $.AXUIElementCopyAttributeValue(element, 'AXTitle', $attr)
                const title = $attr[0] ? $attr[0].js : 'No title'
                console.log(`${indent}  Title: "${title}"`)

                $.AXUIElementCopyAttributeValue(element, 'AXValue', $attr)
                const value = $attr[0] ? $attr[0].js : 'No value'
                console.log(`${indent}  Value: "${value}"`)
            }

            if (role === 'AXHeading' || role === 'AXStaticText') {
                $.AXUIElementCopyAttributeValue(element, 'AXValue', $attr)
                const value = $attr[0] ? $attr[0].js : 'No value'
                console.log(`${indent}  Text: "${value}"`)
            }

            // Recursively explore children
            $.AXUIElementCopyAttributeValue(element, 'AXChildren', $attr)
            if ($attr[0] && $attr[0].js && $attr[0].js.length > 0) {
                console.log(`${indent}  Children (${$attr[0].js.length}):`)
                $attr[0].js.forEach((child, index) => {
                    console.log(`${indent}  [${index}]`)
                    debugUIHierarchy(child, depth + 1, maxDepth)
                })
            }
        } catch (e) {
            console.log(`${indent}Error reading element: ${e}`)
        }
    }

    // Debug: Log all available options to help troubleshoot
    console.log('=== Enhanced Debugging of UI Hierarchy ===')
    console.log(`Exploring ${$children[0].js.length} top-level elements:`)
    $children[0].js.forEach((child, index) => {
        console.log(`\n--- Top-level Element ${index} ---`)
        debugUIHierarchy(child, 0, 4)
    })
    console.log('=== End enhanced debugging ===')

    // Function to recursively search for the target device
    function findTargetDevice(elements, depth = 0) {
        if (depth > 5) return null; // Prevent infinite recursion

        for (const element of elements) {
            try {
                $.AXUIElementCopyAttributeValue(element, 'AXRole', $attr)
                const role = $attr[0] ? $attr[0].js : 'Unknown'

                if (role === 'AXCheckBox') {
                    // Check description
                    $.AXUIElementCopyAttributeValue(element, 'AXDescription', $attr)
                    const description = $attr[0] ? $attr[0].js : ''

                    // Check title as well
                    $.AXUIElementCopyAttributeValue(element, 'AXTitle', $attr)
                    const title = $attr[0] ? $attr[0].js : ''

                    // Try exact match first
                    if (description === TARGET_DEVICE_NAME || title === TARGET_DEVICE_NAME) {
                        console.log(`Found exact match: "${description}" or "${title}"`)
                        return element
                    }

                    // Try partial match (in case there are extra characters)
                    if ((description && description.includes(TARGET_DEVICE_NAME)) ||
                        (title && title.includes(TARGET_DEVICE_NAME))) {
                        console.log(`Found partial match: "${description}" or "${title}" contains "${TARGET_DEVICE_NAME}"`)
                        return element
                    }
                } else if (role === 'AXGroup' || role === 'AXScrollArea' || role === 'AXList') {
                    // Recursively search within containers
                    $.AXUIElementCopyAttributeValue(element, 'AXChildren', $attr)
                    if ($attr[0] && $attr[0].js && $attr[0].js.length > 0) {
                        const foundInGroup = findTargetDevice($attr[0].js, depth + 1)
                        if (foundInGroup) {
                            return foundInGroup
                        }
                    }
                } else if (role === 'AXDisclosureTriangle') {
                    // Try clicking disclosure triangles to expand sections
                    console.log('Found disclosure triangle, attempting to expand...')
                    $.AXUIElementPerformAction(element, 'AXPress')
                    delay(0.5) // Wait for UI to update

                    // Re-search the parent container after expansion
                    const parent = elements.find(el => el === element)
                    if (parent) {
                        // Get updated children after expansion
                        $.AXUIElementCopyAttributeValue(mirroringOptions, 'AXChildren', $children)
                        const foundAfterExpansion = findTargetDevice($children[0].js, depth + 1)
                        if (foundAfterExpansion) {
                            return foundAfterExpansion
                        }
                    }
                }
            } catch (e) {
                console.log(`Error processing element at depth ${depth}: ${e}`)
                continue
            }
        }
        return null
    }

    if (!deviceToggle) {
        console.log('Device not found in initial search, trying to expand disclosure triangles...')
        const disclosureTriangles = []

        // Collect all disclosure triangles
        function collectDisclosureTriangles(elements) {
            for (const element of elements) {
                try {
                    $.AXUIElementCopyAttributeValue(element, 'AXRole', $attr)
                    const role = $attr[0] ? $attr[0].js : 'Unknown'

                    if (role === 'AXDisclosureTriangle') {
                        disclosureTriangles.push(element)
                    } else if (role === 'AXGroup' || role === 'AXScrollArea' || role === 'AXList') {
                        $.AXUIElementCopyAttributeValue(element, 'AXChildren', $attr)
                        if ($attr[0] && $attr[0].js && $attr[0].js.length > 0) {
                            collectDisclosureTriangles($attr[0].js)
                        }
                    }
                } catch (e) {
                    console.log(`Error collecting disclosure triangle: ${e}`)
                }
            }
        }

        collectDisclosureTriangles($children[0].js)
        console.log(`Found ${disclosureTriangles.length} disclosure triangles to expand`)

        // Try expanding each disclosure triangle and search again
        for (const triangle of disclosureTriangles) {
            try {
                console.log('Expanding disclosure triangle...')
                $.AXUIElementPerformAction(triangle, 'AXPress')
                delay(1) // Wait longer for UI to update

                // Refresh the children after expansion
                $.AXUIElementCopyAttributeValue(mirroringOptions, 'AXChildren', $children)

                // Search again with the expanded UI
                deviceToggle = findTargetDevice($children[0].js)
                if (deviceToggle) {
                    console.log('Found device after expanding disclosure triangle!')
                    break
                }
            } catch (e) {
                console.log(`Error expanding disclosure triangle: ${e}`)
            }
        }
    }

    if (!deviceToggle) {
        console.log('Error: Could not get toggle for target screen-mirroring device.')
        console.log('Target device name:', TARGET_DEVICE_NAME)
        console.log('Please check the debug output above to see available device names.')
        return 1
    }

    console.log('Found target device, performing final toggle...')
    // Check current state and perform action
    $.AXUIElementCopyAttributeValue(deviceToggle, 'AXValue', $attr)
    const currentValue = $attr[0] ? $attr[0].js : 0

    if (currentValue === 1) {
        console.log('Device is connected, clicking to disconnect...')
    } else {
        console.log('Device is disconnected, clicking to connect...')
    }

    $.AXUIElementPerformAction(deviceToggle, 'AXPress')
    console.log('Toggle operation completed')
    return 0
}

// prettier-ignore
(() => {
    ObjC.import('Cocoa'); // yes, it's necessary -- stop telling me it isn't

    ObjC.bindFunction('AXUIElementPerformAction', ['int', ['id', 'id']]);
    ObjC.bindFunction('AXUIElementCreateApplication', ['id', ['unsigned int']]);
    ObjC.bindFunction('AXUIElementCopyAttributeValue', ['int', ['id', 'id', 'id*']]);
    ObjC.bindFunction('AXUIElementCopyAttributeNames', ['int', ['id', 'id*']]);
})();