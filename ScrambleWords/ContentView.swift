//
//  ContentView.swift
//  ScrambleWords
//
//  Created by ahmad kaddoura on 1/15/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    @State private var score = 0
    
    var body: some View {
        VStack{
            
        }
        NavigationStack{
            
            List{
                Section{
                    TextField("Enter word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section{
                    ForEach(usedWords, id:\.self){
                        word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
                
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame )
            .alert(errorTitle, isPresented: $showError) {
                Button("ok"){}
            }message: {
                Text(errorMessage)
                    .font(.headline)
            }
            VStack{
                Text("Score: \(score)")
                Button("Refresh"){
                    startGame()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        
        .padding()
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Try again")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "Words must come from the string '\(rootWord)'")
            return
        }
        
        guard isRealWord(word:answer ) else{
            wordError(title: "Word not recognized", message: "Must use real word")
            return
        }
        withAnimation{
            usedWords.insert(answer, at:0)
            score += answer.count
            
        }
            newWord = ""
    }
    
    func startGame(){
        if let startWordsUrl = Bundle.main.url(forResource: "start",withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsUrl){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        fatalError("Cannot load start.txt forom bundle")
    }
    
    func isOriginal(word: String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        var temp = rootWord
        for letter in word{
            if let pos = temp.firstIndex(of:letter){
                temp.remove(at:pos)
            }else{
                return false
            }
        }
        return true
    }
    
    func isRealWord(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let missplelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return missplelledRange.location == NSNotFound
    }
    
    func wordError(title : String, message : String){
        errorTitle = title
        errorMessage = message
        showError = true
    }
    
}

#Preview {
    ContentView()
}
