//
//  BiometricPasscodeView.swift
//  Preferences
//
//  Settings > [Face ID/Touch ID] & Passcode
//

import SwiftUI

struct BiometricPasscodeView: View {
    // Variables
    @AppStorage("PasscodeEnabled") private var passcodeEnabled = true
    @AppStorage("FaceIDIsSetup") private var isFaceIDSetup = false
    @AppStorage("PasscodeOffLocked") private var passcodeOffLocked = false
    
    @AppStorage("SiriEnabled") private var siriEnabled = false
    @State private var allowFingerprintForUnlock = false
    @State private var allowFingerprintForStore = false
    @State private var allowFingerprintForContactlessPayment = false
    @State private var forceAuthenticationBeforeAutoFill = false

    @State private var allowMaskUnlock = false
    @State private var requireAttentionForUnlock = true
    @State private var attentionAwareFeatures = true
    @State private var voiceDial = true

    @State private var allowLockScreenTodayView = true
    @State private var allowLockScreenNotificationsView = true
    @State private var allowLockScreenControlCenter = true
    @State private var allowLockScreenWidgets = true
    @State private var allowLockScreenLiveActivities = true
    @State private var allowAssistantWhileLocked = true
    @State private var allowReplyWhileLocked = true
    @State private var allowHomeControlWhileLocked = true
    @State private var allowPassbookWhileLocked = false
    @State private var allowReturnCallsWhileLocked = true
    @State private var allowUSBRestrictedMode = false

    @State private var allowEraseAfterFailedAttempts = false
    @State private var showingEraseConfirmation = false

    @State private var opacity: Double = 0
    @State private var frameY: Double = 0
    @State private var showingHelpSheet = false
    @State private var showingPrivacySheet = false

//    @State private var isFaceIDSetup = false
    
    @State private var showDisablePasscodeAlert = false
    @State private var showPasscodeSheetForDisable = false
//    @State private var passcodeOffLocked = false


    let table = "Pearl"
    let lockTable = "Passcode Lock"
    let payTable = "Payment_Prefs"
    let oldTable = "TouchID"
    let dtoTable = "PasscodeLock-DimpleKey"

    var body: some View {
        CustomList {
            Placard(
                title: UIDevice.PearlIDCapability ? "PEARL_ID_AND_PASSCODE".localize(table: table) : "TOUCHID_PASSCODE".localize(table: oldTable),
                color: UIDevice.PearlIDCapability ? .green : .white,
                icon: UIDevice.PearlIDCapability ? "faceid" : "touchid",
                description: "\(UIDevice.PearlIDCapability ? "PASSCODE_PLACARD_SUBTITLE_FACE_ID".localize(table: lockTable) : "PASSCODE_PLACARD_SUBTITLE_TOUCH_ID".localize(table: lockTable)) [\("PASSCODE_RECOVERY_LEARN_MORE_TEXT".localize(table: lockTable))](pref://helpkit)",
                frameY: $frameY,
                opacity: $opacity
            )

            // Face ID / Touch ID toggles section
            Section {
                Toggle("TOUCHID_UNLOCK".localize(table: oldTable), isOn: $allowFingerprintForUnlock)
                Toggle("TOUCHID_PURCHASES".localize(table: oldTable), isOn: $allowFingerprintForStore)
                Toggle("TOUCHID_STOCKHOLM".localize(table: payTable), isOn: $allowFingerprintForContactlessPayment)
                Toggle("SAFARI_AUTOFILL".localize(table: oldTable), isOn: $forceAuthenticationBeforeAutoFill)
            } header: {
                Text(UIDevice.PearlIDCapability ? "PEARL_HEADER".localize(table: table) : "USE_TOUCHID_FOR".localize(table: oldTable))
            } footer: {
                Text(.init(UIDevice.PearlIDCapability
                           ? "PEARL_FOOTER".localize(table: table, "[\("PEARL_FOOTER_LINK".localize(table: table))](pref://privacy)")
                           : "Touch ID lets you use your fingerprint to unlock your device and make purchases with Apple Pay, App Store, and Apple Books. [About Touch ID & Privacy…](pref://privacy)"))
            }
            
            // --- Alternate Appearance & Mask ---
            if UIDevice.PearlIDCapability && isFaceIDSetup {
                Section {
                    Button("Thiết lập diện mạo thay thế") {
                    }
                    .foregroundStyle(.blue)
                } footer: {
                    Text("Ngoài việc liên tục ghi nhớ ngoại hình của bạn, Face ID còn có thể nhận ra diện mạo thay thế.")
                        .foregroundStyle(.secondary)
                }

                Section {
                    Toggle("Face ID với khẩu trang", isOn: $allowMaskUnlock)
                } footer: {
                    Text("Face ID hoạt động chính xác nhất khi được thiết lập để chỉ nhận diện toàn bộ khuôn mặt. Để sử dụng Face ID khi đeo khẩu trang, iPhone có thể nhận dạng các đặc điểm duy nhất xung quanh vùng mắt để xác thực. Bạn phải nhìn vào iPhone của mình để sử dụng Face ID khi đeo khẩu trang.")
                        .foregroundStyle(.secondary)
                }
            }

            if UIDevice.PearlIDCapability {
                // Set Up / Reset Face ID
                Section {
                    Button(isFaceIDSetup ? "RESET_FACE_ID".localize(table: table) : "SET_UP_FACE_ID".localize(table: table)) {
                        withAnimation(.easeInOut) {
                            isFaceIDSetup.toggle()
                            passcodeOffLocked = false
                            passcodeEnabled = true
                        }
                    }
                    .foregroundStyle(isFaceIDSetup ? Color.red : Color.blue)
                }

                Section {
                    Toggle("PEARL_UNLOCK_ATTENTION_TITLE".localize(table: table), isOn: $requireAttentionForUnlock)
                } header: {
                    Text("ATTENTION_HEADER", tableName: table)
                } footer: {
                    Text("PEARL_ATTENTION_FOOTER".localize(table: table) + "\(UIDevice.iPhone ? " Face ID will always require attention when you‘re wearing a mask." : "")")
                }

                Section {
                    Toggle("PEARL_ATTENTION_TITLE".localize(table: table), isOn: $attentionAwareFeatures)
                } footer: {
                    Text("PEARL_ATTENTION_FEATURES_FOOTER", tableName: table)
                }

                if UIDevice.iPhone {
                    Section {
                        SettingsLink("DTO_STATUS_LABEL_DESCRIPTION".localize(table: dtoTable), status: "DTO_STATUS_LABEL_DESCRIPTION_STATE_OFF".localize(table: dtoTable), destination: EmptyView())
                            .disabled(true)
                    } footer: {
                        Text(UIDevice.PearlIDCapability ? "DTO_GROUP_DISABLED_REASON_FOOTER_DESCRIPTION_FACE_ID" : "DTO_GROUP_DISABLED_REASON_FOOTER_DESCRIPTION_TOUCH_ID", tableName: dtoTable)
                    }
                }
            } else {
                Section("FINGERPRINTS".localize(table: oldTable)) {
                    Button("ADD_FINGERPRINT".localize(table: oldTable)) {}
                }
            }

            // Passcode buttons
            Section {
                Button("PASSCODE_OFF".localize(table: lockTable)) {
                    showDisablePasscodeAlert = true
                }
                .disabled(isFaceIDSetup || passcodeOffLocked)

                Button("CHANGE_PASSCODE".localize(table: lockTable)) {
                }
                .foregroundStyle(.blue)
            }
            .alert("Tắt mật mã?", isPresented: $showDisablePasscodeAlert) {
                Button("CANCEL".localize(table: lockTable), role: .cancel) { }
                Button("Tắt".localize(table: lockTable), role: .destructive) {
                    showPasscodeSheetForDisable = true
                }
            } message: {
                Text("Các ứng dụng yêu cầu Face ID, bao gồm ứng dụng bị ẩn, sẽ không yêu cầu Face ID nữa và sẽ xuất hiện lại trên Màn hình chính của bạn.")
            }

            Section {
                SettingsLink("PASSCODE_REQ".localize(table: lockTable), status: "ALWAYS".localize(table: lockTable), destination: EmptyView())
                    .disabled(true)
            }

            Section {
                Toggle("VOICE_DIAL".localize(table: lockTable), isOn: $voiceDial)
                    .disabled(true)
            } footer: {
                Text("VOICE_DIAL_TEXT", tableName: lockTable)
            }

            // Lock screen access toggles (disabled group)
            Section {
                Toggle("TODAY_VIEW".localize(table: lockTable), isOn: $allowLockScreenTodayView)
                Toggle("NOTIFICATIONS_VIEW".localize(table: lockTable), isOn: $allowLockScreenNotificationsView)
                Toggle("CONTROL_CENTER".localize(table: lockTable), isOn: $allowLockScreenControlCenter)
                Toggle("COMPLICATIONS".localize(table: lockTable), isOn: $allowLockScreenWidgets)
                Toggle("LIVE_ACTIVITIES".localize(table: lockTable), isOn: $allowLockScreenLiveActivities)
                if siriEnabled {
                    Toggle("Siri", isOn: $allowAssistantWhileLocked)
                }
                if UIDevice.iPhone {
                    Toggle("REPLY_WITH_MESSAGE".localize(table: lockTable), isOn: $allowReplyWhileLocked)
                }
                Toggle("HOME_CONTROL".localize(table: lockTable), isOn: $allowHomeControlWhileLocked)
                if UIDevice.iPhone {
                    Toggle("WALLET".localize(table: lockTable), isOn: $allowPassbookWhileLocked)
                }
                Toggle("RETURN_MISSED_CALLS".localize(table: lockTable), isOn: $allowReturnCallsWhileLocked)
                Toggle("ACCESSORIES".localize(table: lockTable), isOn: $allowUSBRestrictedMode.animation())
            } header: {
                Text("ALLOW_ACCESS_WHEN_LOCKED", tableName: lockTable)
            } footer: {
                Text(allowUSBRestrictedMode ? "ACCESSORIES_ON" : "ACCESSORIES_OFF", tableName: lockTable)
            }
            .disabled(true)

            Section {
                Toggle("WIPE_DEVICE".localize(table: lockTable), isOn: $allowEraseAfterFailedAttempts)
                    .disabled(true)
                    .confirmationDialog(
                        "WIPE_DEVICE_ALERT_TITLE".localize(table: lockTable),
                        isPresented: $showingEraseConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("WIPE_DEVICE_ALERT_OK".localize(table: lockTable), role: .destructive) {}
                        Button("CANCEL".localize(table: lockTable), role: .cancel) {
                            allowEraseAfterFailedAttempts = false
                        }
                    }
                    .onChange(of: allowEraseAfterFailedAttempts) { newValue in
                        showingEraseConfirmation = newValue
                    }
            } footer: {
                Text("WIPE_DEVICE_TEXT".localize(table: lockTable, "10"))
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(UIDevice.PearlIDCapability ? "PEARL_ID_AND_PASSCODE".localize(table: table) : "TOUCHID_PASSCODE".localize(table: oldTable))
                    .fontWeight(.semibold)
                    .font(.subheadline)
                    .opacity(frameY < 50.0 ? opacity : 0)
            }
        }
        .onOpenURL { url in
            if url.absoluteString == "pref://helpkit" {
                showingHelpSheet = true
            } else if url.absoluteString == "pref://privacy" {
                showingPrivacySheet = true
            }
        }
        .sheet(isPresented: $showingHelpSheet) {
            HelpKitView(topicID: UIDevice.iPhone ? (UIDevice.PearlIDCapability ? "iph6d162927a" : "iph672384a0b") : (UIDevice.PearlIDCapability ? "ipad66441e44" : "ipadcb11e17d"))
                .ignoresSafeArea(edges: .bottom)
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingPrivacySheet) {
            OnBoardingKitView(bundleID: UIDevice.PearlIDCapability ? "com.apple.onboarding.faceid" : "com.apple.onboarding.touchid")
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showPasscodeSheetForDisable) {
            PasscodeSheet(
                onCancel: {
                    showPasscodeSheetForDisable = false
                },
                onSuccess: {
                    showPasscodeSheetForDisable = false
                    passcodeOffLocked = true
                    passcodeEnabled = false
                }
            )
            .presentationDetents([.large])
            .interactiveDismissDisabled(true)
        }

    }
}

#Preview {
    NavigationStack {
        BiometricPasscodeView()
    }
}
