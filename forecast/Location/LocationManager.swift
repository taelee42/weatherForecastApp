//
//  LocationManager.swift
//  forecast
//
//  Created by Terry Lee on 2021/05/17.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()
    private override init() {
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        super.init()
        
        manager.delegate = self
    }
    
    let manager: CLLocationManager
    
    var currentLocationTitle: String? {
        didSet {
            var userInfo = [AnyHashable: Any]()
            if let location = currentLocation {
                userInfo["location"] = location
            }
            
            NotificationCenter.default.post(name: Self.currentLocationDidUpdate, object: nil, userInfo: userInfo)
        }
    }
    //좌표를 받아서 WeatherAPI로 보낼 정보를 담는 변수
    var currentLocation: CLLocation?
    
    static let currentLocationDidUpdate = Notification.Name("currentLocationDidUpdate")
    func updateLocation() {
        let status: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            requestAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        case .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    //권한을 요청하는 코드
    //이 메소드가 아래 requestCurrentLocation보다 먼저 호출돼야 한다.
    private func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    //현재 위치를 요청하는 코드
    private func requestCurrentLocation() {
//        manager.startUpdatingLocation()
        manager.requestLocation()
        //이 메소드가 제대로 실행되면 아래 didUpdateLocations가 호출되고
        //실패하면 didFailWithError 메소드가 호출된다.
    }
        
    private func updateAddress(from Location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(Location) { [weak self] (placemarks, error) in
            if let error = error {
                self?.currentLocationTitle = "Unknown"
                return
            }
            if let placemark = placemarks?.first {
                if let gu = placemark.locality, let dong = placemark.subLocality {
                    self?.currentLocationTitle = "\(gu) \(dong)"
                } else {
                    self?.currentLocationTitle = placemark.name ?? "Unknown"
                }
            }
            
            print(self?.currentLocationTitle)
        }
    }

    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        case .notDetermined, .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        case .notDetermined, .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
    }
    
    //새로운 위치정보가 전달되면 반복적으로 호출됨
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations.last)
        
        if let location = locations.last {
            currentLocation = location
            updateAddress(from: location)
        }
    }
    
    //에러가 발생되면 호출되는 메소드
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
