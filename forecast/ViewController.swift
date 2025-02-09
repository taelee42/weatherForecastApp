//
//  ViewController.swift
//  forecast
//
//  Created by Terry Lee on 2021/05/10.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var listTableView: UITableView!
    
    var topInset = CGFloat(0.0)
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if topInset == 0.0 {
            let firstIndexPath = IndexPath(row: 0, section: 0)
            if let cell = listTableView.cellForRow(at: firstIndexPath) {
                topInset = listTableView.frame.height - cell.frame.height
                
                var inset = listTableView.contentInset
                inset.top = topInset
                listTableView.contentInset = inset
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.alpha = 0.0
        loader.alpha = 1.0
        
        listTableView.backgroundColor = .clear
        listTableView.separatorStyle = .none
        listTableView.showsVerticalScrollIndicator = false
        
//        let location = CLLocation(latitude: 37.498206, longitude: 127.02761)
//        WeatherDataSource.shared.fetch(location: location) {
//            self.listTableView.reloadData()
//        }
        
        LocationManager.shared.updateLocation()
        
        NotificationCenter.default.addObserver(forName: WeatherDataSource.weatherInfoDidUpdate, object: nil, queue: .main) { (noti) in
            self.listTableView.reloadData()
            self.locationLabel.text = LocationManager.shared.currentLocationTitle
            
            UIView.animate(withDuration: 0.3) {
                self.listTableView.alpha = 1.0
                self.loader.alpha = 0.0
            }
        }
    }


}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            return WeatherDataSource.shared.forecastList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryTableViewCell") as! SummaryTableViewCell
            
            if let weather = WeatherDataSource.shared.summary?.weather.first, let main = WeatherDataSource.shared.summary?.main {
                cell.weatherImageView.image = UIImage(named: weather.icon)
                cell.statusLabel.text = weather.description
                cell.minMaxLabel.text = "최고 \(main.temp_max.temperatureString) 최소 \(main.temp_min.temperatureString)"
                cell.currentTemperatureLabel.text = "\(main.temp.temperatureString)"
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell") as! ForecastTableViewCell
        let target = WeatherDataSource.shared.forecastList[indexPath.row]
        cell.dateLabel.text = target.date.dateString
        cell.timeLabel.text = target.date.timeString
        cell.weatherImageView.image = UIImage(named: target.icon)
        cell.statusLabel.text = target.weather
        cell.temperatureLabel.text = target.temperature.temperatureString
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
}
