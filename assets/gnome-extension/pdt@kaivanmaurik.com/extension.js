/**
 * PDT Gnome Extension
 * 
 * @copyright kaivanmaurik.com
 */

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

class Extension {

    constructor() 
    {
        console.log(`pdt: constructing ${Me.metadata.name}`);
    }

    enable() {
        let last_window_id_list;
        let customerFacingDisplayWindowId;

        last_window_id_list = global.get_window_actors().map(w => w.meta_window.get_id());
        customerFacingDisplayWindowId = -1;

        console.log(`pdt: enabling ${Me.metadata.name}`);
        global.window_change_signal = global.display.connect('window-created', () => 
        {
            for (let i = 0; i < global.get_window_actors().length; i++) 
            {
                let current_window_id_list;
                let meta;

                meta = global.get_window_actors()[i].meta_window;
                current_window_id_list = global.get_window_actors().map(w => w.meta_window.get_id());
        
                if(last_window_id_list.includes(meta.get_id()))
                    continue;
                if(!meta || meta.get_window_type() > 1) //0=normal & 1=desktop, 2=dock, etc.
                    continue;
                waitForString(() => {
                    if(!meta || meta._destroyed) return "";
                    else return meta.get_title();
                }).then((result) => 
                {
                    console.log("pdt: Title identified: " + result);
                    if (result.includes("CustomerFacingDisplay")) 
                    {
                        console.log("pdt: CustomerFacingDisplay detected."); 
                        if(customerFacingDisplayWindowId != -1 && current_window_id_list.includes(customerFacingDisplayWindowId))
                        {
                            for(let j = 0; j < global.get_window_actors().length; j++)
                            {
                                if(global.get_window_actors()[j].meta_window.get_id() == customerFacingDisplayWindowId)
                                    global.get_window_actors()[j].kill();
                            }
                        }
                        if(global.display.get_n_monitors() > 1)
                        {
                            meta.move_to_monitor(1);
                            meta.make_fullscreen();
                            console.log("pdt: Applied actions succesfully.");
                        }
                        else
                            console.log("pdt: No second monitor found. No actions applied.");
                    }
                }).catch(err => {
                    console.log("pdt: Error while getting title: " + err.message);
                });
            }
            last_window_id_list = global.get_window_actors().map(w => w.meta_window.get_id());
        });
    }

    disable() {
        if(global.window_change_signal) 
        {
            global.display.disconnect(global.window_change_signal);
            global.window_change_signal = null;
        }
        console.log(`pdt: disabling ${Me.metadata.name}`);
    }
}

function waitForString(getString, interval = 100) 
{
    return new Promise((resolve, reject) => {
        if (typeof getString !== "function") 
        {
            reject(new Error("Expected a function as the first argument."));
            return;
        }

        try {
            const checkInterval = setInterval(() => 
            {
                let value = getString();
                if (typeof value === "string" && value.trim() !== "" && value !== "Mozilla Firefox") 
                {
                    clearInterval(checkInterval);
                    resolve(value);
                }
            }, interval);
        } 
        catch(error) 
        {
            console.log("pdt: Window no longer exists. Returning empty title");
            resolve("Empty Title");
        }
    });
}

/**
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
