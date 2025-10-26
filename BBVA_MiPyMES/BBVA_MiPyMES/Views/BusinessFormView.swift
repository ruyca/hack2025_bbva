import SwiftUI

struct BusinessFormView: View {
    @Environment(\.dismiss) var dismiss
    @State private var businessName = ""
    @State private var businessDescription = ""
    @State private var businessCategory = "Retail"
    @State private var businessPhone = ""
    @State private var businessEmail = ""
    @State private var businessAddress = ""
    @State private var businessHours = ""
    @State private var logoURL = ""
    @State private var socialMedia = ""
    @State private var isGenerating = false
    @State private var generatedWebURL = ""
    @State private var showSuccessAlert = false
    
    let categories = ["Retail", "Restaurante", "Servicios", "Tecnología", "Salud", "Educación", "Otro"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.BBVABackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Formulario
                        formSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.vertical, 20)
                }
                
                // Botón fijo en la parte inferior
                VStack {
                    Spacer()
                    
                    Button(action: {
                        generateWebsite()
                    }) {
                        HStack(spacing: 12) {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "globe")
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text("Crear Página Web")
                                    .font(.system(size: 17, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.BBVABlue,
                                    Color.BBVATeal
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: Color.BBVABlue.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .disabled(isGenerating || !isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.6)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.BBVABackground.opacity(0),
                                Color.BBVABackground
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Atrás")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(Color.BBVABlue)
                    }
                }
            }
        }
        .alert("¡Sitio Web Creado!", isPresented: $showSuccessAlert) {
            Button("Copiar URL") {
                UIPasteboard.general.string = generatedWebURL
            }
            Button("Cerrar", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Tu página web ha sido creada exitosamente:\n\(generatedWebURL)")
        }
    }
    
    // MARK: - Header Section
    
    var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.BBVABlue.opacity(0.2),
                                Color.BBVATeal.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color.BBVABlue)
            }
            
            VStack(spacing: 8) {
                Text("Crea tu Página Web")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.BBVACharcoal)
                
                Text("Completa la información de tu negocio para generar tu sitio web personalizado")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Form Section
    
    var formSection: some View {
        VStack(spacing: 20) {
            // Información básica
            formCard(title: "Información Básica") {
                VStack(spacing: 16) {
                    customTextField(
                        icon: "building.2.fill",
                        placeholder: "Nombre del Negocio",
                        text: $businessName
                    )
                    
                    customTextEditor(
                        icon: "text.alignleft",
                        placeholder: "Descripción del Negocio",
                        text: $businessDescription
                    )
                    
                    customPicker(
                        icon: "list.bullet",
                        title: "Categoría",
                        selection: $businessCategory,
                        options: categories
                    )
                }
            }
            
            // Información de contacto
            formCard(title: "Contacto") {
                VStack(spacing: 16) {
                    customTextField(
                        icon: "phone.fill",
                        placeholder: "Teléfono",
                        text: $businessPhone,
                        keyboardType: .phonePad
                    )
                    
                    customTextField(
                        icon: "envelope.fill",
                        placeholder: "Email",
                        text: $businessEmail,
                        keyboardType: .emailAddress
                    )
                    
                    customTextField(
                        icon: "mappin.circle.fill",
                        placeholder: "Dirección",
                        text: $businessAddress
                    )
                }
            }
            
            // Información adicional
            formCard(title: "Información Adicional") {
                VStack(spacing: 16) {
                    customTextField(
                        icon: "clock.fill",
                        placeholder: "Horario (ej: Lun-Vie 9:00-18:00)",
                        text: $businessHours
                    )
                    
                    customTextField(
                        icon: "photo.fill",
                        placeholder: "URL del Logo (opcional)",
                        text: $logoURL
                    )
                    
                    customTextField(
                        icon: "link",
                        placeholder: "Redes Sociales (opcional)",
                        text: $socialMedia
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Custom Components
    
    func formCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
            
            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    func customTextField(icon: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.BBVABlue.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.BBVABlue)
            }
            
            TextField(placeholder, text: text)
                .font(.system(size: 16))
                .foregroundColor(Color.BBVACharcoal)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.BBVALightGray.opacity(0.3))
        )
    }
    
    func customTextEditor(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.BBVABlue.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.BBVABlue)
            }
            .padding(.top, 4)
            
            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 16))
                        .foregroundColor(Color.BBVATextSecondary.opacity(0.5))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                
                TextEditor(text: text)
                    .font(.system(size: 16))
                    .foregroundColor(Color.BBVACharcoal)
                    .frame(minHeight: 80)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.BBVALightGray.opacity(0.3))
        )
    }
    
    func customPicker(icon: String, title: String, selection: Binding<String>, options: [String]) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.BBVABlue.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.BBVABlue)
            }
            
            Picker(title, selection: selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .font(.system(size: 16))
            .foregroundColor(Color.BBVACharcoal)
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.BBVALightGray.opacity(0.3))
        )
    }
    
    // MARK: - Helper Functions
    
    var isFormValid: Bool {
        !businessName.isEmpty &&
        !businessDescription.isEmpty &&
        !businessPhone.isEmpty &&
        !businessEmail.isEmpty
    }
    
    func generateWebsite() {
        isGenerating = true
        
        // Preparar datos para la petición
        let businessData: [String: Any] = [
            "name": businessName,
            "description": businessDescription,
            "category": businessCategory,
            "phone": businessPhone,
            "email": businessEmail,
            "address": businessAddress,
            "hours": businessHours,
            "logo": logoURL,
            "socialMedia": socialMedia
        ]
        
        // Simular petición al servidor
        // En producción, aquí harías la petición real a tu API
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // URL simulada - reemplazar con respuesta real del servidor
            generatedWebURL = "https://mipyme.\(businessName.lowercased().replacingOccurrences(of: " ", with: "")).impulsa-bbva.com"
            isGenerating = false
            showSuccessAlert = true
            
            // Aquí harías la petición real:
            /*
            guard let url = URL(string: "https://tu-servidor.com/api/generate-website") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: businessData)
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        isGenerating = false
                        
                        if let data = data,
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let url = json["url"] as? String {
                            generatedWebURL = url
                            showSuccessAlert = true
                        }
                    }
                }.resume()
            } catch {
                isGenerating = false
                print("Error: \(error)")
            }
            */
        }
    }
}

struct BusinessFormView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessFormView()
    }
}
