# 🚀 Task Management System

A clean and efficient **Task Management Application** built using Flutter, designed to help users manage daily tasks with ease.  
This project demonstrates core application development skills including CRUD operations, local storage handling, and UI design.

---

## ✨ Features

- ➕ Add new tasks  
- ✏️ Edit existing tasks  
- 🗑️ Delete tasks  
- ✅ Mark tasks as completed  
- 💾 Persistent storage using Hive (local database)  
- 🎨 Simple and user-friendly interface  

---

## 🛠️ Tech Stack

| Technology | Usage |
|-----------|------|
| Flutter   | Frontend Development |
| Dart      | Programming Language |
| Hive      | Local Database |

---
## 📸 Screenshots

### 🏠 Home Screen
![Home Screen](screenshots/home.png)

### ➕ Add Task Screen
![Add Task](screenshots/add_task.png)

### 📋 Task List
![Task List](screenshots/task_list.png)

### 🔄 Task Status Update
![Task Status](screenshots/task_status.png)

### 🔍 Filter Tasks
![Filter Tasks](screenshots/filter.png)

### 🌙 Dark Mode
![Dark Mode](screenshots/dark_mode.png)

## ⚙️ How It Works

- The application uses **Hive** as a local database to store tasks on the device.
- Each task contains details like title, description, and status (completed/pending).
- Users can:
  - Add a new task → Stored in Hive  
  - Edit a task → Updates existing data  
  - Delete a task → Removes from storage  
  - Mark task as completed → Updates task status  
- UI updates dynamically based on stored data.

---

## ▶️ How to Run the Project

Follow these steps to run the project on your system:

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/nishikant636/Task-Management-App.git
cd Task-Management-App
