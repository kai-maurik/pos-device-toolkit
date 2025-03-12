/**
 * PDT Gnome Extension
 * 
 * @copyright kaivanmaurik.com
 */

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

let last_window_id_list;
let customerFacingDisplayWindowId = -1;

class Extension {
    constructor() {
        console.log(`pdt: constructing ${Me.metadata.name}`);
    }

    /**
     * This function is called when your extension is enabled, which could be
     * done in GNOME Extensions, when you log in or when the screen is unlocked.
     *
     * This is when you should setup any UI for your extension, change existing
     * widgets, connect signals or modify GNOME Shell's behavior.
     */
    enable() {
        console.log(`pdt: enabling ${Me.metadata.name}`);
        last_window_id_list = global.get_window_actors().map(w => w.meta_window.get_id());
        
        global.window_change_signal = global.display.connect('window-created', () => {
            for(let i = 0; i < global.get_window_actors().length; i++) {
                let window_actor = global.get_window_actors()[i];
                let current_window_id_list = global.get_window_actors().map(w => w.meta_window.get_id());

                if(last_window_id_list.includes(window_actor.meta_window.get_id()))
                    continue;

                if(!window_actor.meta_window || window_actor.meta_window.get_window_type() > 1) //0=normal & 1=desktop, 2=dock, etc.
                    continue;

                console.log("pdt: Window open registered: " + window_actor.meta_window.get_id());

                // Bug3: Sometimes when closing windows throws error for this line. This only appears when popup menus happen. Ignore
                waitForString(() => window_actor.meta_window.get_title()).then((result) => {
                    console.log("pdt: Title identified: " + result)
                    if(result.includes("CustomerFacingDisplay")) {
                        // Customer display found in the window_actor
                        console.log("pdt: CustomerFacingDisplay detected. Applying actions...");

                        if(customerFacingDisplayWindowId != -1 && current_window_id_list.includes(customerFacingDisplayWindowId)) {
                            for(let j = 0; j < global.get_window_actors().length; j++) {
                                if(global.get_window_actors()[j].meta_window.get_id() == customerFacingDisplayWindowId)
                                    global.get_window_actors()[j].kill(); // Care: untested
                            }
                        }

                        if(global.display.get_n_monitors() > 1) {
                            window_actor.meta_window.move_to_monitor(1); // Care: untested
                            window_actor.meta_window.make_fullscreen();
                        }
                    }
                }).catch();
            }
            
            last_window_id_list = global.get_window_actors().map(w => w.meta_window.get_id());
        });
    }


    /**
     * This function is called when your extension is uninstalled, disabled in
     * GNOME Extensions or when the screen locks.
     *
     * Anything you created, modified or setup in enable() MUST be undone here.
     * Not doing so is the most common reason extensions are rejected in review!
     */
    disable() {
        console.log(`pdt: disabling ${Me.metadata.name}`);
    }
}

function waitForString(getString, interval = 100) {
    return new Promise((resolve, reject) => {
        if (typeof getString !== "function") {
            reject(new Error("Expected a function as the first argument."));
            return;
        }

        try {
            const checkInterval = setInterval(() => {
                let value = getString();
                if (typeof value === "string" && value.trim() !== "") {
                    clearInterval(checkInterval);
                    resolve(value);
                }
            }, interval);
        } catch(error) {
            console.log("pdt: Window no longer exists. Returning empty title");
            resolve("Empty Title");
        }
    });
}

/**
 * This function is called once when your extension is loaded, not enabled. This
 * is a good time to setup translations or anything else you only do once.
 *
 * You MUST NOT make any changes to GNOME Shell, connect any signals or add any
 * MainLoop sources here.
 *
 * @param {ExtensionMeta} meta - An extension meta object
 * @returns {object} an object with enable() and disable() methods
 */
function init(meta) {
    console.debug(`initializing ${meta.metadata.name}`);

    // If just one monitor is present, the cfd will not be able to move
    if(global.display.get_n_monitors() < 2)
        console.warn("pwh: No second monitor detected for the CustomerFacingDisplay. Auto move disabled.")

    return new Extension();
}
