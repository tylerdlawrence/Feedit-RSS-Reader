//
//  TabFormat.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 10/23/20.
//

import SwiftUI

struct CustomSlideMenu: View {

    var body: some View {

        Home()
    }
}
struct CustomSlideMenu_Previews: PreviewProvider {
    static var previews: some View {
        CustomSlideMenu()
    }
}
struct HomePage : View {
    
    @Binding var x : CGFloat
    
    var body: some View{
        
        // Home View With CUstom Nav bar...
        
        VStack{
            
            HStack{
                
                Button(action: {
                    
                    // opening menu,...
                    
                    withAnimation{
                        
                        x = 0
                    }
                    
                }) {
                    
                    Image(systemName: "line.horizontal.3")
                        .font(.system(size: 24))
                        .foregroundColor(Color("twitter"))
                }
                
                Spacer(minLength: 0)
                
                Text("Twitter")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer(minLength: 0)
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
            
            Spacer()
        }
        // for drag gesture...
        .contentShape(Rectangle())
        .background(Color.white)
    }
}

struct Home : View {
    
    // for future use...
    @State var width = UIScreen.main.bounds.width - 90
    // to hide view...
    @State var x = -UIScreen.main.bounds.width + 90
    
    var body: some View{
        
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
            
            HomePage(x: $x)
            
            SlideMenu()
                .shadow(color: Color.black.opacity(x != 0 ? 0.1 : 0), radius: 5, x: 5, y: 0)
                .offset(x: x)
                .background(Color.black.opacity(x == 0 ? 0.5 : 0).ignoresSafeArea(.all, edges: .vertical).onTapGesture {
                    
                    // hiding the view when back is pressed...
                    
                    withAnimation{
                        
                        x = -width
                    }
                })
        }
        // adding gesture or drag feature...
        .gesture(DragGesture().onChanged({ (value) in
            
            withAnimation{
                
                if value.translation.width > 0{
                    
                    // disabling over drag...
                    
                    if x < 0{
                        
                        x = -width + value.translation.width
                    }
                }
                else{

                    if x != -width{
                    
                        x = value.translation.width
                    }
                }
            }
            
        }).onEnded({ (value) in
            
            withAnimation{
                
                // checking if half the value of menu is dragged means setting x to 0...
                
                if -x < width / 2{
                    
                    x = 0
                }
                else{
                    
                    x = -width
                }
            }
        }))
    }
}

struct SlideMenu : View {
    
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @State var show = true
    
    var body: some View{
        
        HStack(spacing: 0){
            
            VStack(alignment: .leading){
                
                Image("logo")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                HStack(alignment: .top, spacing: 12) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Kavsoft")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("@_Kavsoft")
                            .foregroundColor(.gray)
                        
                        .padding(.top,10)
                        
                        Divider()
                            .padding(.top,10)
                    }
                    
                    Spacer(minLength: 0)
                    
                    Button(action: {
                        
                        withAnimation{
                            
                            show.toggle()
                        }
                        
                    }) {
                        
                        Image(systemName: show ? "chevron.down" : "chevron.up")
                            .foregroundColor(Color("twitter"))
                    }
                }
                
                // Different Views When up or down buttons pressed....
                
                VStack(alignment: .leading){
                    
                    // Menu Buttons....
                    
                    ForEach(menuButtons,id: \.self){menu in
                        
                        Button(action: {
                            // switch your actions or work based on title....
                        }) {
                            
                            MenuButton(title: menu)
                        }
                    }
                    
                    Divider()
                        .padding(.top)
                    
                    Button(action: {
                        // switch your actions or work based on title....
                    }) {
                        
                        MenuButton(title: "Twitter Ads")
                    }
                    
                    Divider()
                    
                    Button(action: {}) {
                        
                        Text("Settings and privacy")
                            .foregroundColor(.black)
                    }
                    .padding(.top)
                    
                    Button(action: {}) {
                        
                        Text("Help center")
                            .foregroundColor(.black)
                    }
                    .padding(.top,20)
                    
                    Spacer(minLength: 0)
                    
                    Divider()
                        .padding(.bottom)
                    
                    HStack{
                        
                        Button(action: {}) {
                            
                            Image("help")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 26, height: 26)
                                .foregroundColor(Color("twitter"))
                        }
                        
                        Spacer(minLength: 0)
                        
                        Button(action: {}) {
                            
                            Image("barcode")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 26, height: 26)
                                .foregroundColor(Color("twitter"))
                        }
                    }
                }
                // hiding this view when down arrow pressed...
                .opacity(show ? 1 : 0)
                .frame(height: show ? nil : 0)
                
                // Alternative View For Up Arrow...
                
                VStack(alignment: .leading){
                    
                    Button(action: {}) {
                        
                        Text("Create a new account")
                            .foregroundColor(Color("twitter"))
                    }
                    .padding(.bottom)
                    
                    Button(action: {}) {
                        
                        Text("Add an existing account")
                            .foregroundColor(Color("twitter"))
                    }
                    
                    Spacer(minLength: 0)
                }
                .opacity(show ? 0 : 1)
                .frame(height: show ? 0 : nil)
                
                
            }
            .padding(.horizontal,20)
            // since vertical edges are ignored....
            .padding(.top,edges!.top == 0 ? 15 : edges?.top)
            .padding(.bottom,edges!.bottom == 0 ? 15 : edges?.bottom)
            // default width...
            .frame(width: UIScreen.main.bounds.width - 90)
            .background(Color.white)
            .ignoresSafeArea(.all, edges: .vertical)
            
            Spacer(minLength: 0)
        }
    }
}

var menuButtons = ["Profile","Lists","Topics","Bookmarks","Moments"]

struct MenuButton : View {
    
    var title : String
    
    var body: some View{
        
        HStack(spacing: 15){
            
            // both title and image names are same....
            Image(title)
                .resizable()
                .renderingMode(.template)
                .frame(width: 24, height: 24)
                .foregroundColor(.gray)
            
            Text(title)
                .foregroundColor(.black)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical,12)
    }
}
