//
//  SwiperizeItemModifier.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/21/20.
//

import SwiftUI

public extension View {
    func SwiperizeItem(closureL: @escaping () -> (), closureR: @escaping () -> ()) -> some View
    {
        self.modifier( SwiperizeItemModifier(closureL: closureL, closureR: closureR) )
    }
}

struct SwiperizeItemModifier: ViewModifier {
    @State var dragOffset = CGSize.zero
    
    @State var offset1Shown = CGSize(width: 100, height: 0)
    @State var offset1Click = CGSize(width: 250, height: 0)
    
    @State var offset2Shown = CGSize(width: -100, height: 0)
    @State var offset2Click = CGSize(width: -250, height: 0)
    
    @State var BackL = Color.green
    @State var BackR = Color.red
    @State var ForeColorL = Color.white
    @State var ForeColorR = Color.white
    
    @State var closureL: () -> Void
    @State var closureR: () -> Void
    
    func body(content: Content) -> some View {
        HStack{
            Button(action: { closureL() } ) {
                HStack{
                Image("unread-action")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .frame(maxWidth: dragOffset.width > 0 ? dragOffset.width : 0)
//                Text("Left")
                    .foregroundColor(Color("Color"))
                //Image(systemName: "star.fill")
                }
            }
            //.background(Color("Color"))
            .frame(maxWidth: dragOffset.width > 0 ? dragOffset.width : 0)
            .fixedSize()
            
            
            content
                .padding([.leading, .trailing], 20)
                .animation(.spring())
                .offset(x: self.dragOffset.width)
                .gesture(DragGesture()
                            .onChanged(){
                                value in
                                self.dragOffset = value.translation
                            }
                            .onEnded(){
                                value in
                                if ( dragOffset.width > 0 ) {
                                    if ( dragOffset.width < offset1Shown.width) {
                                        self.dragOffset = .zero
                                    }
                                    else if ( dragOffset.width > offset1Shown.width &&  dragOffset.width < offset1Click.width ) {
                                        self.dragOffset = offset1Shown
                                    }
                                    else if ( dragOffset.width > offset1Click.width ) {
                                        self.dragOffset = .zero
                                        closureR()
                                    }
                                }
                                else {
                                    if ( dragOffset.width > offset2Shown.width) {
                                        self.dragOffset = .zero
                                    }
                                    else if ( dragOffset.width < offset2Shown.width && dragOffset.width > offset2Click.width ) {
                                        self.dragOffset = offset2Shown
                                    }
                                    else if ( dragOffset.width < offset2Click.width ) {
                                        self.dragOffset = .zero
                                        closureL()
                                    }
                                }
                            }
                )
        }
    }
}



// ____________________

struct GuestureItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Text("Hello")
                .padding(.all, 30)
                .background( Color(.red) )
                .SwiperizeItem(closureL: { print("click left") }, closureR: { print("click right") })
        }
    }
}
