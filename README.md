



#### 📱 이 프로젝트는 kxcoding.com의 Step By Step Weather App 강의를 통해 만든 `날씨 App`입니다.

# 날씨 앱

![forecast view low-min](https://user-images.githubusercontent.com/55867479/118953266-9ff89200-b997-11eb-9e91-754c3feef768.gif)

## 1. 화면 구성

<img width="200" alt="Screen Shot 2021-05-19 at 12 04 15 AM" src="https://user-images.githubusercontent.com/55867479/118953296-a71fa000-b997-11eb-84fa-8e573ce9427d.png">

- 화면은 하나의 테이블 뷰가 2개의 섹션으로 나뉘어져 있습니다.
- 첫번째 섹션에는 현재 날씨를 표시하는 셀이 1개 표시됩니다.
- 두번째 섹션에는 날씨 예보를 표시하는 셀이 API서버에서 가져온 갯수만큼 표시됩니다.

<img width="200" alt="메인화면 스크롤전 2" src="https://user-images.githubusercontent.com/55867479/118953300-a7b83680-b997-11eb-8a02-1e402b86e5da.png">


- 실제로 앱을 구동하면 가운데 여백이 있는데 이부분은 테이블뷰의 contenInset으로 1번째 섹션의 높이를 동적으로 계산하여 맨밑에 배치되도록 합니다.
- 위에 3개의 빨간색 사각형중 가운데가 Inset부분입니다. 첫번째 섹션의 시작이 3번째 사각형부분 입니다.


## 2. 프로젝트 구조

### 📁 폴더 구조
```
Forecast/
├─ Location/
│  ├─ LocationManager.swift
├─ Formatter/
│  ├─ Double+Formatter.swift
│  ├─ Date+Formatter.swift
├─ Data/
│  ├─ WeatherDataSource.swift
├─ Model/
│  ├─ ApiError.swift
│  ├─ CurrentWeather.swift
│  ├─ Forecast.swift
├─ Cell/
│  ├─ SummaryTableViewCell.swift
│  ├─ ForecastTableViewCell.swift
AppDelegate.swift
SceneDelegate.swift
Common.swift
ViewController.swift
Main.storyboard
LaunchScreen.storyboard
Info.plist
```

#### 📁 LocationManager
- 위치에 관련된 권한을 확인하고 사용자에게 요청합니다. (CLLocationManager, CLAuthorizationStatus)
  - iOS 14.0 이상에서는 CLLocationManager의 인스턴스 메서드인 authorizatinoStatus로 초기화합니다.
  - 그 이하버전에서는 CLLocationManager.authorizationStatus() 타입 메서드로 초기화합니다.
- 권한의 확인은 CLLocationManagerDelegate를 채용해서 확인합니다.
  - requestWhenInUseAuthorization()으로 권한을 요청합니다. 
  - requestLocation()으로 위치를 요청합니다. 
- 위치를 요청하는 코드를 권한을 요청한 뒤 호출해야 합니다.
- 요청한 위치는 2가지 형태로 사용됩니다.
  - 첫째) 위치를 reverseGeocoder를 사용해 `00구 00동` 형식의 주소로 변환하여 메인화면상단에 표시합니다.
  - 둘째) 위치를 통해 OpenWeatherMap.org API서버(이하 API서버)로 요청을 보내 날씨 정보를 받아옵니다.
- 외부에서 사용될 변수 목록
  - `currentLocationTitle: String?`: oo구 oo동 형식의 주소형식 이 변수에 property observer를 달아서 주소가 바뀌었다는 사실을 NotificationCenter에 전달합니다. 전체적인 NotificationCenter의 구조는 밑에서 다시 설명하겠습니다.
  - `currentLocation: CLAuthorizationStatus` : API서버에 요청할 주소 데이터, 여기에서 감지된 변화는 별도의 Notification으로 처리하지 않고 위의 `currentLocationTitle`에서 같이 처리해줍니다.

#### 📁 Formatter

##### Double+Formatter.swift

- 온도 표시 형식을 설정합니다.
- `MeasurementFormatter()`를 통해 소수점 통일과 `°(도, degree)` 를 표시합니다.

##### Date+Formatter.swift

- 예보에 필요한 날짜와 시간 형식을 설정합니다.
- `DateFormtter()`를 통해 시간 형식을 아래와 같이 통일하였습니다.
날짜: `M월 d일`형식
시간: `HH:00`형식

#### 📁 Model

#### CurrrentWeather.swift
CurrentWeather
- API서버로부터 받은 "현재날씨" 데이터의 JSON파일을 담을 타입을 설정합니다.

#### Forecast.swift
Forecast
- API서버로부터 받은 "날씨예보" 데이터의 JSON파일을 담을 타입을 설정합니다.

ForecastData
- 구조체가 중첩된 형식의 데이터인 Forecast 타입을 간결하게 만든 타입입니다.

#### ApiError.swift
- API서버로 요청을 보냈을때 발생할 수 있는 Error 열거형입니다.


### 📁 Data/WeatherDataSource.swift

- 기능1) LocationManger에서 알아낸 위치를 observer를 통해 감지합니다.
- 기능2) 감지된 위치 주소를 Notification에 담아 ViewController로 보냅니다.
- 기능3) 감지된 위치 정보로 API서버로 날씨정보를 요청합니다.
  - 날씨 정보는 
  fetchCurrentWeather(location: , completion:), fetchForecast(location: ,completion) 로 현재날씨와 예보날씨를 따로 요청합니다.
  - 둘다 fetch(urlStr: , completion)을 호출하는데 여기서 Result타입을 통해 성공된 데이터와 실패시 Error을 담아 리턴합니다.
  - fetch(location: , completion) 함수를 다시 만들어 내부에서 fetch(urlStr: , completion)의 성공 데이터와 에러를 처리하고 NotificationCenter에 알려줍니다.


## 3. Notification Center를 통한 데이터 전달

이 프로젝트에서는 아래 2개의 Notification이 있습니다.

1 currentLocationDidUpdate
  - 현재 위치를 디바이스로부터 받으면 currentLocationTitle 프로퍼티가 업데이트 되고 property observer를 통해 Notification이 post 됩니다.
  - 위의 Notification은 WeatherDataSource 클래스의 생성자에 Observer가 감시하고 있습니다.
  - Observer가 Notification을 감지하면 2가지 일을 합니다.
    1) API서버로 위에서 받은 위치정보에 대한 날씨 정보를 호출합니다.
    2) 아래 Notification을 post합니다.

2 weatherInfoDidUpdate
  - 1의 Notification을 observer가 감지하면 2번째 Notification이 post됩니다.
  - 이 Notification의 Observer는 ViewContorller.swift의 viewDidLoad에 구현되어 있습니다.
  - 여기에서 Observer가 Notification을 감지하면 alpha값이 0이었던 테이블뷰의 alpha값이 1이 되고 Acitivity Indicator가 사라집니다.