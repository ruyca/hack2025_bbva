//
//  ChatView.swift
//  BBVA_MiPyMES
//
//  Created by Ruy Cabello on 13/05/25.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var chatViewModel = ChatViewModel()
    @State private var currentMessageText: String = ""
    @State private var showingClearConfirmation = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .top) {
            // Blue header background that extends to top edge
            VStack {
                Color("primaryBlue")
                    .frame(height: 150)
                    .edgesIgnoringSafeArea(.top)
                Spacer()
            }
            
            // Main content
            VStack(spacing: 0) {
                // Header title
                VStack {
                    Spacer().frame(height: 55)
                    HStack {
                        Image("Jimmy") // The AI assistant image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        
                        Text("Pym - Asistente BBVA")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Removed the clear history button from header since we now have it at the bottom
                    }
                }
                .frame(height: 120)
                .padding(.horizontal)
                
                // Chat content area with white background and rounded corners
                VStack {
                    // Messages area
                    ScrollViewReader { scrollView in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(chatViewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding()
                            .onChange(of: chatViewModel.messages.count) { _ in
                                if let lastMessage = chatViewModel.messages.last {
                                    withAnimation {
                                        scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Input area
                    HStack {
                        TextField("Escribe tu mensaje...", text: $currentMessageText)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        
                        Button(action: {
                            send()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .padding(12)
                                .background(Color("primaryBlue"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(currentMessageText.isEmpty)
                    }
                    .padding()
                }
                .background(Color.white)
                .clipShape(RoundedCornerShape(radius: 20, corners: [.topLeft, .topRight]))
                .padding(.top, -20)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert(isPresented: $showingClearConfirmation) {
            Alert(
                title: Text("Limpiar historial"),
                message: Text("¿Estás seguro que deseas eliminar todo el historial del chat? Esta acción no se puede deshacer."),
                primaryButton: .destructive(Text("Eliminar")) {
                    chatViewModel.clearHistory()
                },
                secondaryButton: .cancel(Text("Cancelar"))
            )
        }
        .onAppear {
            chatViewModel.setup()
        }
    }
    
    func send() {
        guard !currentMessageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let messageToSend = currentMessageText
        currentMessageText = ""
        
        chatViewModel.send(text: messageToSend) { _ in
            // Response handling is managed in the ViewModel
        }
    }
}

struct MessageBubble: View {
    var message: ChatMessage
    
    var body: some View {
        VStack(alignment: message.author == "Me" ? .trailing : .leading) {
            HStack {
                if message.author == "Me" {
                    Spacer()
                    
                    Text(message.text)
                        .padding()
                        .background(Color("primaryBlue"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                } else {
                    if message.author == "Pym" {
                        Image("Jimmy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    }
                    
                    Text(message.text)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(16)
                    
                    Spacer()
                }
            }
            
            Text(formatDate(message.timestamp))
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(message.author == "Me" ? .trailing : .leading, 8)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

