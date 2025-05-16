# Final_Project

MileMark is a SwiftUI-based mobile app that helps users track vehicle mileage and maintenance schedules. It integrates with Firebase to handle user authentication, car data storage, and maintenance history. The app automatically notifies users after 7 days to update the milage on their cars. 

Features  
    Add & Manage Vehicles  
        -Track make, model, year, and current mileage  
        -Horizontally scrollable car cards with selection and edit/delete options  
        
Maintenance Tracking  
        -Predefined and custom maintenance types (e.g. oil changes, tire rotations)  
        -Log maintenance at current mileage  
        -See next due maintenance based on interval  
        
 Firebase Authentication  
        -Sign up / login with email & password  
        -Email verification required before login  
        -Logout and session handling  
        
Local Notifications  
        -Users receive mileage reminders via iOS local notifications  
        -Automatically scheduled when logging mileage or adding a car  
        
Dynamic UI  
        -Dark mode support (cards adapt to system appearance)  
        -Responsive layout across devices  


  Setup Instructions  
Clone the Repo  
    git clone https://github.com/UWP-iOS-Dev-Class/final-project-MattSeck.git  
    cd MileMark  
    
Open in Xcode  
    open MileMark.xcodeproj  
    
Firebase Setup  
Create a Firebase project at https://console.firebase.google.com  
Download GoogleService-Info.plist and add it to your Xcode project  
Enable:  
Authentication → Email/Password  
Firestore Database  

Run the App  

Not completed features:  
    User can upload their own image for each car  
    Change password function  
    Add App Icon  
    
Future plan:  
    Finish and implement the uncompleted features  
    
