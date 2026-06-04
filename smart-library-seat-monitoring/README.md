# Smart Library Seat Monitoring

Real-time IoT system developed to monitor seat occupancy inside the Library of the School of Engineering and Technological Sciences.

## Overview

The project was designed to provide students with real-time information about available seats in the library through a web dashboard connected to an IoT infrastructure.

Each monitored seat is equipped with a distance sensor connected to an STM32 microcontroller. The occupancy status is transmitted wirelessly through Bluetooth and stored in Firebase Realtime Database. A web application displays seat availability in real time.

## Features

* Real-time seat monitoring
* Automatic occupancy detection
* Temporary absence management ("In Verification" state)
* Bluetooth communication
* Cloud synchronization with Firebase
* Interactive web dashboard

## Hardware

* STM32 Nucleo-F401RE
* VL53L0X Time-of-Flight Distance Sensor
* HC-05 / HC-06 Bluetooth Module

## Software

* STM32CubeIDE (C)
* Node.js
* Firebase Realtime Database
* HTML
* CSS
* JavaScript
* Vite

## System Architecture

STM32 + VL53L0X Sensor → Bluetooth Communication → Node.js Bridge → Firebase Realtime Database → Web Dashboard

## Seat States

### Available

The seat is free and available for use.

### Occupied

A user is currently detected.

### In Verification

The system waits 30 seconds before marking a seat as available again, preventing false detections when a user temporarily leaves the seat.

## Project Status

Work in progress.  
The web dashboard and Firebase integration are implemented, while the hardware communication is currently being tested and improved.

## Future Improvements

* Mobile application
* Occupancy statistics and analytics

## Authors

Sara Auditano

Federica Capuano

Ciro Pazzi

B.Sc. Telecommunications Engineering

University of Naples Parthenope
