//
//  ContentView.swift
//  w24-189e-hw1
//
//  Created by Sam King on 1/4/24.
//

import SwiftUI
//import UIKit
import PhoneNumberKit

struct EnterPhoneNumberView: View {
    
    @State var phoneNumberString: String = ""
    @State var phoneNumberColor = Color.primary
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
        
        let e164PhoneNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
        print(e164PhoneNumber)
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
                Text("Next").bold()
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            }
            .buttonStyle(.borderedProminent)
            
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
    EnterPhoneNumberView()
}
