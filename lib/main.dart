import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/weather_model.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
      ),
      home: const HomePage()
    );
  }
}
 class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> sehirler =["Giresun","Bursa","Burdur","Ankara","İzmir","İstanbul","Trabzon","Antalya"];

  String? secilenSehir;
  Future<WeatherModel>? weatherFuture;

  void selectedCity(String sehir) {
    setState(() {
      secilenSehir=sehir;
      weatherFuture=getWeather(sehir);
    });

  }

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5',
      queryParameters: {
        "appid": '{Your API Key}',
        "lang": 'tr',
        "units": 'metric'
      },
    )
  );

  Future<WeatherModel> getWeather(String secilenSehir) async {
    final response=await dio.get('/weather',queryParameters: {
      "q":secilenSehir
    });
    var model=WeatherModel.fromJson(response.data);
    debugPrint(model.main?.temp.toString());
    return model;
  }

 Widget _buildWeatherCard(WeatherModel weatherModel) {
  final String backgroundImage = _getCityBackgroundImage(weatherModel.name!);
  
  return Container(
    margin: EdgeInsets.all(16),
    height: 250, // Sabit yükseklik ekliyoruz
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // Arka plan resmi
          Image.asset(
            backgroundImage,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          
          // Koyu overlay (yazıların okunabilir olması için)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.2),
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          
          // Hava durumu bilgileri
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weatherModel.name!,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "${weatherModel.main!.temp!.round()}°",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  weatherModel.weather![0].description?.toUpperCase() ?? 'DEĞER BULUNAMADI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.water_drop, color: Colors.white, size: 24),
                        SizedBox(height: 4),
                        Text(
                          "%${weatherModel.main!.humidity!.round()}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 32),
                    Column(
                      children: [
                        Icon(Icons.air, color: Colors.white, size: 24),
                        SizedBox(height: 4),
                        Text(
                          "${weatherModel.wind!.speed!.round()} m/s",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  currentDateTime,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 5,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// yeni alan 
String _getCityBackgroundImage(String cityName) {
  switch (cityName.toLowerCase()) {
    case 'giresun':
      return 'assets/giresun.jpg';
    case 'bursa':
      return 'assets/bursa.jpg';
    case 'burdur':
      return 'assets/burdur.jpg';
    case 'ankara':
      return 'assets/ankara.jpg';
    case 'izmir':
      return 'assets/izmir.jpg';
    case 'istanbul':
      return 'assets/istanbul.jpg';
    case 'trabzon':
      return 'assets/trabzon.jpg';
    case 'antalya':
      return 'assets/antalya.jpg';
    default:
      return 'assets/teal.jpg';
  }
}

Timer? _timer;
String currentDateTime = '';

@override
void initState() {
  super.initState();
  _startTimer();
}

@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}

void _startTimer() {
  // İlk değeri ayarla
  _updateDateTime();
  
  // Her dakika güncelle (60 saniye * 1000 milisaniye)
  _timer = Timer.periodic(Duration(seconds: 60), (timer) {
    _updateDateTime();
  });
}

void _updateDateTime() {
  setState(() {
    currentDateTime = _getFormattedDateTime();
  });
}

String _getFormattedDateTime() {
  final now = DateTime.now();
  final days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
  final months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year} • ${now.hour+3}:${now.minute.toString().padLeft(2, '0')}';
}

// yeni alan son

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Hava Durumu"),
        ),
        body: Column(
          children: [
            if(weatherFuture!=null)
            FutureBuilder(future: weatherFuture, builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
              }
              if(snapshot.hasError){
                return Center(child: Text(snapshot.hasError.toString()),);
              }
              if(snapshot.hasData){
                return _buildWeatherCard(snapshot.data!);
              }
              return SizedBox();
            },),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
              gridDelegate:
               SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16), 
            itemBuilder: (context, index) {
              final isSelected = secilenSehir == sehirler[index];
              return GestureDetector(
                onTap: () => selectedCity(sehirler[index]),
                child: Card(
                  color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                  child: Center(
                    child: Text(sehirler[index]),
                  ),
                ),
              );
              
            }, itemCount: sehirler.length,))
          ],
        ),
      );
  }
  
  
  
  
}
