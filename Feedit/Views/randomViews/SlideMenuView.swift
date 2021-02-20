//
//  ContentView.swift
//  Custom Slide Out Menu
//
//  Created by Kavsoft on 27/03/20.
//  Copyright © 2020 Kavsoft. All rights reserved.
//

import SwiftUI

struct SlideMenuView: View {
    
    @State var index = "Home"
    @State var show = false
    
    var body: some View {
        
        ZStack{
            
            (self.show ? Color.black.opacity(0.05) : Color.clear).edgesIgnoringSafeArea(.all)
            
            ZStack(alignment: .leading) {
                
                VStack(alignment : .leading,spacing: 25){
                    
                    HStack(spacing: 15){
                        
                        Image("pic")
                        .resizable()
                        .frame(width: 65, height: 65)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            Text("Feedit: RSS Reader")
                                .fontWeight(.bold)
                            
                            //Text("subtitle here??")
                        }
                    }
                    .padding(.bottom, 50)

                    
                    ForEach(data,id: \.self){i in
                        
                        Button(action: {
                            
                            self.index = i
                            
                            withAnimation(.spring()){
                                
                                self.show.toggle()
                            }
                            
                        }) {
                            
                            HStack{
                                
                                Capsule()
                                .fill(self.index == i ? Color.orange : Color.clear)
                                .frame(width: 5, height: 30)
                                
                                Text(i)
                                    .padding(.leading)
                                    .foregroundColor(.black)
                                
                            }
                        }
                    }
                    
                    Spacer()
                }.padding(.leading)
                .padding(.top)
                .scaleEffect(self.show ? 1 : 0)
                
                ZStack(alignment: .topTrailing) {
                    MainSlideView(show: self.$show,index: self.$index)
                    .scaleEffect(self.show ? 0.8 : 1)
                    .offset(x: self.show ? 150 : 0,y : self.show ? 50 : 0)
                    .disabled(self.show ? true : false)
                    
                    
                    Button(action: {
                        
                        withAnimation(.spring()){
                            
                            self.show.toggle()
                        }
                        
                    }) {
                        
                        Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.black)
                        
                    }.padding()
                    .opacity(self.show ? 1 : 0)
                }
                
            }
        }
    }
}

struct SlideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SlideMenuView()
    }
}

struct MainSlideView : View {

    @Binding var show : Bool
    @Binding var index : String
    
    var body : some View{
        
        VStack(spacing: 0){
            
            ZStack{
                
                HStack{
                    
                    Button(action: {
                        
                        withAnimation(.spring()){
                            
                            self.show.toggle()
                        }
                        
                    }) {
                        
                        Image("Menu")
                        .resizable()
                        .frame(width: 20, height: 15)
                        .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        
                        Image("menudot")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.black)
                    }
                }
                
                Text("Feeds")
                    .fontWeight(.bold)
                    .font(.title)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            ZStack{
                
                HotLinks().opacity(self.index == "Hot Links" ? 1 : 0)
                
                Unread().opacity(self.index == "Unread" ? 1 : 0)
                
                Bookmarked().opacity(self.index == "Bookmarked" ? 1 : 0)
                
                SettingView().opacity(self.index == "Settings" ? 1 : 0)
                
                Help().opacity(self.index == "Help" ? 1 : 0)
            }
            
        }.background(Color.white)
        .cornerRadius(15)
    }
}

struct SlideListView : View {
   
    var body : some View{
    
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing : 18){

                ForEach(1...6,id: \.self){i in

                    Image("p\(i)")
                    .resizable()
                    .frame(height: 250)
                    .cornerRadius(20)
                }
            }.padding(.top, 8)
            .padding(.horizontal)
        }
    }
}

struct HotLinks : View {
    
    var body : some View{
        
        GeometryReader{_ in
            
            VStack{
                
                Text("Hot Links")
            }
        }
    }
}

struct Unread : View {
    
    var body : some View{
        
        GeometryReader{_ in
            
            VStack{
                
                Text("Unread")
            }
        }
    }
}

struct Bookmarked : View {
    
    var body : some View{
        
        GeometryReader{_ in
            
            VStack{
                
                Text("Bookmarked")
            }
        }
    }
}

struct SettingSlideMenuView : View {
    
    var body : some View{
        
        GeometryReader{_ in
            
            VStack{
                
                Text("Settings")
            }
        }
    }
}

struct Help : View {
    
    var body : some View{
        
        GeometryReader{_ in
            
            VStack{
                
                Text("About")
            }
        }
    }
}


var data = ["Feeds","Hot Links","Unread","Bookmarked","Settings","About"]
