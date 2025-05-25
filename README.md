**📘 HackerSenpaiAdmin (Admin App)**
------------------------------------

> An admin app for teachers to manage students and courses securely, built with **Flutter** and **Firebase**.

### **🔧 Features**

*   🔐 Secure Firebase Authentication for admin login
    
*   *   Name, Email, Student ID, Password
        
    *   Subject selection via multi-select (e.g., Accounts, Economics)
        
*   🧑‍💻 Creates Firebase Auth user credentials for students automatically
    
*   🗃️ Stores student metadata in Firestore /users collection
    
*   *   Add/edit/delete courses
        
    *   Add chapters under each course
        
    *   Add videos under each chapter (name, description, and **YouTube** video link)
        

*   *   Prevent screen recording and screenshots
        
    *   Device Root Check (app exits if rooted)
        

### **🚀 Getting Started**

1.  Clone the repo
    
2.  Run flutter pub get
    
3.  Setup Firebase for Android & iOS
    
4.  Add your Firebase google-services.json and GoogleService-Info.plist
    
5.  Add required packages:
    

firebase\_core

firebase\_auth

cloud\_firestore

device\_info\_plus

flutter\_windowmanager

1.  Launch on Android or iOS
    

### **📁 Directory Highlights**

*   /screens/manage\_students.dart – Add, edit, delete students
    
*   /screens/manage\_courses.dart – Add/edit/delete courses, chapters, videos
    
*   /services/firebase\_service.dart – Firebase logic and user creation
    
*   /utils/root\_check.dart – Checks if device is rooted


