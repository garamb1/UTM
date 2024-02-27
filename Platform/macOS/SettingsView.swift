//
// Copyright © 2020 osy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

@available(macOS 11, *)
struct SettingsView: View {
    
    var body: some View {
        TabView {
            ApplicationSettingsView().padding()
                .tabItem {
                    Label("Application", systemImage: "app.badge")
                }
            DisplaySettingsView().padding()
                .tabItem {
                    Label("Display", systemImage: "rectangle.on.rectangle")
                }
            SoundSettingsView().padding()
                .tabItem {
                    Label("Sound", systemImage: "speaker.wave.2")
                }
            InputSettingsView().padding()
                .tabItem {
                    Label("Input", systemImage: "keyboard")
                }
        }.frame(minWidth: 600, minHeight: 350, alignment: .topLeading)
    }
}

struct ApplicationSettingsView: View {
    @AppStorage("KeepRunningAfterLastWindowClosed") var isKeepRunningAfterLastWindowClosed = false
    @AppStorage("HideDockIcon") var isDockIconHidden = false
    @AppStorage("ShowMenuIcon") var isMenuIconShown = false
    @AppStorage("PreventIdleSleep") var isPreventIdleSleep = false
    @AppStorage("NoQuitConfirmation") var isNoQuitConfirmation = false
    
    var body: some View {
        Form {
            Toggle(isOn: $isKeepRunningAfterLastWindowClosed, label: {
                Text("Keep UTM running after last window is closed and all VMs are shut down")
            })
            if #available(macOS 13, *) {
                Toggle(isOn: $isDockIconHidden.inverted, label: {
                    Text("Show dock icon")
                }).onChange(of: isDockIconHidden) { newValue in
                    if newValue {
                        isMenuIconShown = true
                        isKeepRunningAfterLastWindowClosed = true
                    }
                }
                Toggle(isOn: $isMenuIconShown, label: {
                    Text("Show menu bar icon")
                }).disabled(isDockIconHidden)
            }
            Toggle(isOn: $isPreventIdleSleep, label: {
                Text("Prevent system from sleeping when any VM is running")
            })
            Toggle(isOn: $isNoQuitConfirmation, label: {
                Text("Do not show confirmation when closing a running VM")
            }).help("Closing a VM without properly shutting it down could result in data loss.")
        }
    }
}

struct DisplaySettingsView: View {
    @AppStorage("DisplayFixed") var isVMDisplayFixed = false
    @AppStorage("NoSaveScreenshot") var isNoSaveScreenshot = false
    @AppStorage("QEMURendererBackend") var qemuRendererBackend: UTMQEMURendererBackend = .qemuRendererBackendDefault
    @AppStorage("QEMURendererFPSLimit") var qemuRendererFpsLimit: Int = 0
    
    var body: some View {
        Form {
            Section(header: Text("Display")) {
                Toggle(isOn: $isVMDisplayFixed, label: {
                    Text("VM display size is fixed")
                }).help("If enabled, resizing of the VM window will not be allowed.")
                Toggle(isOn: $isNoSaveScreenshot) {
                    Text("Do not save VM screenshot to disk")
                }.help("If enabled, any existing screenshot will be deleted the next time the VM is started.")
            }
            
            Section(header: Text("QEMU Graphics Acceleration")) {
                Picker("Renderer Backend", selection: $qemuRendererBackend) {
                    Text("Default").tag(UTMQEMURendererBackend.qemuRendererBackendDefault)
                    Text("ANGLE (OpenGL)").tag(UTMQEMURendererBackend.qemuRendererBackendAngleGL)
                    Text("ANGLE (Metal)").tag(UTMQEMURendererBackend.qemuRendererBackendAngleMetal)
                }.help("By default, the best renderer for this device will be used. You can override this with to always use a specific renderer. This only applies to QEMU VMs with GPU accelerated graphics.")
                HStack {
                    Stepper("FPS Limit", value: $qemuRendererFpsLimit, in: 0...240, step: 15)
                    NumberTextField("", number: $qemuRendererFpsLimit, prompt: "None")
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                        .help("If set, a frame limit can improve smoothness in rendering by preventing stutters when set to the lowest value your device can handle.")
                }
            }
        }
    }
}

struct SoundSettingsView: View {
    @AppStorage("QEMUSoundBackend") var qemuSoundBackend: UTMQEMUSoundBackend = .qemuSoundBackendDefault
    
    var body: some View {
        Form {
            Section(header: Text("QEMU Sound")) {
                Picker("Sound Backend", selection: $qemuSoundBackend) {
                    Text("Default").tag(UTMQEMUSoundBackend.qemuSoundBackendDefault)
                    Text("SPICE with GStreamer (Input & Output)").tag(UTMQEMUSoundBackend.qemuSoundBackendSPICE)
                    Text("CoreAudio (Output Only)").tag(UTMQEMUSoundBackend.qemuSoundBackendCoreAudio)
                }.help("By default, the best backend for the target will be used. If the selected backend is not available for any reason, an alternative will automatically be selected.")
            }
        }
    }
}

struct InputSettingsView: View {
    @AppStorage("FullScreenAutoCapture") var isFullScreenAutoCapture = false
    @AppStorage("OptionAsMetaKey") var isOptionAsMetaKey = false
    @AppStorage("CtrlRightClick") var isCtrlRightClick = false
    @AppStorage("AlternativeCaptureKey") var isAlternativeCaptureKey = false
    @AppStorage("IsCapsLockKey") var isCapsLockKey = false
    @AppStorage("IsNumLockForced") var isNumLockForced = false
    @AppStorage("InvertScroll") var isInvertScroll = false
    @AppStorage("NoUsbPrompt") var isNoUsbPrompt = false
    
    var body: some View {
        Form {
            Section(header: Text("Mouse/Keyboard")) {
                Toggle(isOn: $isFullScreenAutoCapture) {
                    Text("Capture input automatically when entering full screen")
                }.help("If enabled, input capture will toggle automatically when entering and exiting full screen mode.")
            }
            
            Section(header: Text("Console")) {
                Toggle(isOn: $isOptionAsMetaKey, label: {
                    Text("Option (⌥) is Meta key")
                }).help("If enabled, Option will be mapped to the Meta key which can be useful for emacs. Otherwise, option will work as the system intended (such as for entering international text).")
            }
            
            Section(header: Text("QEMU Pointer")) {
                Toggle(isOn: $isCtrlRightClick, label: {
                    Text("Hold Control (⌃) for right click")
                })
                Toggle(isOn: $isInvertScroll, label: {
                    Text("Invert scrolling")
                }).help("If enabled, scroll wheel input will be inverted.")
            }
            
            Section(header: Text("QEMU Keyboard")) {
                Toggle(isOn: $isAlternativeCaptureKey, label: {
                    Text("Use Command+Option (⌘+⌥) for input capture/release")
                }).help("If disabled, the default combination Control+Option (⌃+⌥) will be used.")
                Toggle(isOn: $isCapsLockKey, label: {
                    Text("Caps Lock (⇪) is treated as a key")
                }).help("If enabled, caps lock will be handled like other keys. If disabled, it is treated as a toggle that is synchronized with the host.")
                Toggle(isOn: $isNumLockForced, label: {
                    Text("Num Lock is forced on")
                }).help("If enabled, num lock will always be on to the guest. Note this may make your keyboard's num lock indicator out of sync.")
            }
            
            Section(header: Text("QEMU USB")) {
                Toggle(isOn: $isNoUsbPrompt, label: {
                    Text("Do not show prompt when USB device is plugged in")
                })
            }
        }
    }
}

extension UserDefaults {
    @objc dynamic var KeepRunningAfterLastWindowClosed: Bool { false }
    @objc dynamic var ShowMenuIcon: Bool { false }
    @objc dynamic var HideDockIcon: Bool { false }
    @objc dynamic var PreventIdleSleep: Bool { false }
    @objc dynamic var NoQuitConfirmation: Bool { false }
    @objc dynamic var NoCursorCaptureAlert: Bool { false }
    @objc dynamic var DisplayFixed: Bool { false }
    @objc dynamic var FullScreenAutoCapture: Bool { false }
    @objc dynamic var OptionAsMetaKey: Bool { false }
    @objc dynamic var CtrlRightClick: Bool { false }
    @objc dynamic var NoUsbPrompt: Bool { false }
    @objc dynamic var AlternativeCaptureKey: Bool { false }
    @objc dynamic var IsCapsLockKey: Bool { false }
    @objc dynamic var IsNumLockForced: Bool { false }
    @objc dynamic var NoSaveScreenshot: Bool { false }
    @objc dynamic var InvertScroll: Bool { false }
    @objc dynamic var QEMURendererBackend: Int { 0 }
    @objc dynamic var QEMURendererFPSLimit: Int { 0 }
}

@available(macOS 11, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
