//
//  ContentView.swift
//  BELLI
//
//  Created by CETYS Universidad  on 03/04/25.
//

import SwiftUI


struct Medicamento: Identifiable, Codable {
    let id = UUID()
    var nombre: String
    var dosis: Int
    var caracteristicas: String
    var fecha: Date
    var tomado: Bool = false
}

struct MenuPrincipalView: View {
    @State private var isShowingNuevoTratamiento = false
    @State private var medicamentos: [Medicamento] = []
    @State private var selectedDate = Date()
    @State private var showDateDetails = false
   
    var medicamentosHoy: [Medicamento] {
        medicamentos.filter { Calendar.current.isDate($0.fecha, inSameDayAs: Date()) }
    }
   
    var body: some View {
        NavigationView {
            VStack {
                Text("Resumen de Salud")
                    .font(.title)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
               
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tratamiento")
                        .font(.headline)
                   
                    CalendarView(selectedDate: $selectedDate, showDateDetails: $showDateDetails, medicamentos: $medicamentos)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                   
                    ForEach(medicamentosHoy) { medicamento in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(medicamento.nombre)
                                    .font(.headline)
                                Text("Dosis: \(medicamento.dosis) - \(medicamento.caracteristicas)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("Tomado") {
                                if let index = medicamentos.firstIndex(where: { $0.id == medicamento.id }) {
                                    medicamentos[index].tomado.toggle()
                                }
                            }
                            .foregroundColor(medicamento.tomado ? .green : .blue)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(medicamento.tomado ? Color.green : Color.clear, lineWidth: 2)
                        )
                    }
                   
                    if medicamentosHoy.isEmpty {
                        Text("No hay medicamentos programados para hoy")
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                   
                    Text("Hábitos Saludables")
                        .font(.headline)
                   
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Inicia con energía esta mañana (30 puntos)")
                            .bold()
                        Text("Hoy intenta caminar 15 minutos más que ayer. ¡Gran avance!")
                        HStack {
                            Button("Rechazar") {}
                                .foregroundColor(.red)
                            Spacer()
                            Button("Aceptar") {}
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                .padding()
               
                Spacer()
               
                HStack {
                    NavigationLink(destination: PerfilView()) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Button(action: {
                        isShowingNuevoTratamiento = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $isShowingNuevoTratamiento) {
                        NuevoTratamientoView(medicamentos: $medicamentos)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "globe")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .shadow(radius: 2)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showDateDetails) {
            DetallesDiaView(date: selectedDate, medicamentos: $medicamentos)
        }
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var showDateDetails: Bool
    @Binding var medicamentos: [Medicamento]
   
    let calendar = Calendar.current
    let daysOfWeek = ["D", "L", "M", "M", "J", "V", "S"]
   
    var body: some View {
        VStack {
            Text(monthYearFormatter.string(from: selectedDate))
                .font(.headline)
           
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                }
            }
           
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(daysInMonth(), id: \.self) { date in
                    let day = calendar.component(.day, from: date)
                    let hasMedicamentos = medicamentos.contains { calendar.isDate($0.fecha, inSameDayAs: date) }
                   
                    Button(action: {
                        selectedDate = date
                        showDateDetails = true
                    }) {
                        VStack(spacing: 2) {
                            Text("\(day)")
                                .frame(width: 30, height: 30)
                                .background(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue : Color.clear)
                                .clipShape(Circle())
                                .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? .white : .black)
                           
                            if hasMedicamentos {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                }
            }
        }
    }
   
    private func daysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else { return [] }
       
        var days: [Date] = []
        var currentDate = monthInterval.start
       
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
       
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        for _ in 1..<firstWeekday {
            guard let prevDate = calendar.date(byAdding: .day, value: -1, to: monthInterval.start) else { continue }
            days.insert(prevDate, at: 0)
        }
       
        return days
    }
   
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }
}

struct DetallesDiaView: View {
    let date: Date
    @Binding var medicamentos: [Medicamento]
    @Environment(\.presentationMode) var presentationMode
   
    var medicamentosDelDia: [Medicamento] {
        medicamentos.filter { Calendar.current.isDate($0.fecha, inSameDayAs: date) }
    }
   
    var body: some View {
        NavigationView {
            VStack {
                Text(dateFormatter.string(from: date))
                    .font(.title2)
                    .padding()
               
                List {
                    ForEach(medicamentosDelDia) { medicamento in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(medicamento.nombre)
                                    .font(.headline)
                                Spacer()
                                Text("Dosis: \(medicamento.dosis)")
                            }
                            Text(medicamento.caracteristicas)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete { indices in
                        for index in indices {
                            if let globalIndex = medicamentos.firstIndex(where: { $0.id == medicamentosDelDia[index].id }) {
                                medicamentos.remove(at: globalIndex)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
               
                Button("Agregar Medicamento") {
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
            .navigationTitle("Medicamentos del día")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
   
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }
}

struct NuevoTratamientoView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var medicamentos: [Medicamento]
   
    @State private var nombre = ""
    @State private var dosis = 1
    @State private var caracteristicas = ""
    @State private var fecha = Date()
    @State private var frecuencia = "Diario"
    @State private var horaToma = Date()
    let frecuencias = ["Cada Domingo", "Cada Lunes", "Cada Martes", "Cada Miercoles", "Cada Jueves", "Cada Viernes", "Cada Sabado", "Diario"]
   
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del Medicamento")) {
                    TextField("Nombre", text: $nombre)
                    Stepper("Dosis: \(dosis)", value: $dosis, in: 1...10)
                    TextField("Características", text: $caracteristicas)
                    DatePicker("Fecha inicio", selection: $fecha, displayedComponents: .date)
                    Picker("Frecuencia", selection: $frecuencia) {
                        ForEach(frecuencias, id: \.self) {
                            Text($0)
                        }
                    }
                    DatePicker("Hora", selection: $horaToma, displayedComponents: .hourAndMinute )
                        .datePickerStyle(.graphical)
                }
               
                Section(header: Text("Agregar Fotografías")) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "paperclip")
                            Text("Agregar fotografía de empaque")
                        }
                    }
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "paperclip")
                            Text("Agregar fotografía de tratamiento")
                        }
                    }
                }
               
                Section {
                    Button(action: {
                        let nuevoMedicamento = Medicamento(
                            nombre: nombre,
                            dosis: dosis,
                            caracteristicas: caracteristicas,
                            fecha: fecha,
                            frecuencia: frecuencia,
                            horaToma:horaToma
                        )
                        medicamentos.append(nuevoMedicamento)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Guardar Tratamiento")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(nombre.isEmpty)
                }
            }
            .navigationTitle("Nuevo Tratamiento")
            .navigationBarItems(leading: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct PerfilView: View {
    var body: some View {
        Text("Perfil del Usuario").font(.largeTitle)
    }
}
