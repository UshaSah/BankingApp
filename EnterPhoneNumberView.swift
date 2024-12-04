//
//  ContentView.swift
//  w24-189e-hw1
//
//  Created by Sam King on 1/4/24.
//

import SwiftUI
import PhoneNumberKit


struct LogicView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State var loading = false
    
    
    var body: some View {
        if userViewModel.authToken == nil && userViewModel.currentUser == nil {
                RootView()
            
        } else if userViewModel.authToken != nil && userViewModel.currentUser == nil{
            LoadingView()
        } else  {
            HomePage(userViewModel: _userViewModel)
        }
        
    }
    

}
    
struct RootView: View {
    @State var navigateToVerify = false
    @State var e164PhoneNumber: String = ""
    @State var loading = false
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        NavigationStack {
            EnterPhoneNumberView(e164PhoneNumber: $e164PhoneNumber, navigateToVerify: $navigateToVerify)
                .navigationDestination(isPresented: $navigateToVerify) {
                    VerifyCodeView(phoneNumber: e164PhoneNumber, loading: $loading)
                }
        }
    }
}

struct EnterPhoneNumberView: View {
    @Binding var e164PhoneNumber: String
    @Binding var navigateToVerify: Bool
    
    @State var phoneNumberString: String = ""
    @State var phoneNumberColor = Color.primary
    @State var errorString: String?
    @State var isLoading = false
    @FocusState var keyboardShowing
    
    let phoneNumberKit = PhoneNumberKit()
    
    func phoneNumberChange() {
        phoneNumberColor = .primary
        let formattedNumber = PartialFormatter().formatPartial(phoneNumberString)
        if formattedNumber != phoneNumberString {
            print("set \(formattedNumber)")
            phoneNumberString = formattedNumber
        } else {
            print("skip")
        }
    }
    
    func nextClick() {
        guard let phoneNumber = try? phoneNumberKit.parse(phoneNumberString) else {
            print("invalid phone number")
            phoneNumberColor = .red
            return
        }
        
        Task {
            isLoading = true
            e164PhoneNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
            do {
                let _ = try await Api.shared.sendVerificationToken(e164PhoneNumber: e164PhoneNumber)
                navigateToVerify = true
            } catch let apiError as ApiError {
                phoneNumberColor = .red
                errorString = apiError.message
            }
            isLoading = false
        }
    }
    
    var body: some View {
        VStack {
            Text("Enter your mobile number").bold()
            Spacer().frame(height: 20)
            HStack {
                Text("🇺🇸 +1")
                TextField("(500) 555-1234", text: $phoneNumberString)
                    .keyboardType(.phonePad)
                    .foregroundColor(phoneNumberColor)
                    .focused($keyboardShowing)
                    .onChange(of: phoneNumberString) {
                        phoneNumberChange()
                    }
            }
            .padding([.leading, .trailing])
            Rectangle()
                .padding([.leading, .trailing])
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.5))
            Spacer().frame(height: 24)
            Button {
                nextClick()
            } label: {
                if !isLoading {
                    Text("Next").bold().frame(maxWidth: .infinity)
                } else {
                    ProgressView().tint(.white).frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            //.disabled(isLoading)
            if let errorString = errorString {
                Text(errorString).foregroundStyle(.red)
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            keyboardShowing = false
        }
    }
}

#Preview {
    RootView()
}
