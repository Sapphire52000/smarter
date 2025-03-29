# 🛠️ 하드웨어 체크리스트 (Raspberry Pi)

## 🧭 기본 하드웨어 준비

### Raspberry Pi 준비
- [ ] Raspberry Pi 4 (최소 2GB RAM) 준비
- [ ] Micro SD 카드 (최소 16GB) 준비
- [ ] 전원 공급 장치 (5V 3A) 준비
- [ ] 케이스 및 냉각 팬 (권장)
- [ ] 모니터, HDMI 케이블, 키보드, 마우스 (초기 설정용)

### 운영체제 설정
- [ ] Raspberry Pi OS 다운로드 (64비트 권장)
  - 📘 [Raspberry Pi OS 다운로드](https://www.raspberrypi.org/software/)
- [ ] Raspberry Pi Imager로 OS 설치
- [ ] 초기 설정 (raspi-config)
  ```bash
  sudo raspi-config
  ```
  - [ ] 지역화 설정 (언어, 시간대)
  - [ ] SSH 활성화
  - [ ] I2C 인터페이스 활성화
  - [ ] 카메라 인터페이스 활성화
  - [ ] 네트워크 설정

### 네트워크 설정
- [ ] 와이파이 또는 이더넷 연결 설정
- [ ] 고정 IP 주소 설정 (권장)
  ```bash
  sudo nano /etc/dhcpcd.conf
  ```
- [ ] SSH 키 설정 (보안 강화)
- [ ] 방화벽 설정 (필요시)

## 📷 카메라 연결 및 설정

### Pi 카메라 모듈
- [ ] Pi 카메라 모듈 물리적 연결
  - 📘 [Pi 카메라 연결 가이드](https://www.raspberrypi.org/documentation/accessories/camera.html)
- [ ] 카메라 활성화 확인
  ```bash
  vcgencmd get_camera
  ```
- [ ] 테스트 사진 촬영
  ```bash
  raspistill -o test.jpg
  ```
- [ ] Python 라이브러리 설치
  ```bash
  pip install picamera
  ```
- [ ] 카메라 테스트 코드 작성
  ```python
  from picamera import PiCamera
  from time import sleep
  
  camera = PiCamera()
  camera.start_preview()
  sleep(5)
  camera.capture('image.jpg')
  camera.stop_preview()
  ```

## 🌡️ 센서 연결 및 설정

### MPU6050 진동/가속도 센서
- [ ] MPU6050 센서 I2C 연결
  - VCC → 3.3V
  - GND → GND
  - SCL → GPIO3/SCL
  - SDA → GPIO2/SDA
- [ ] I2C 인터페이스 확인
  ```bash
  sudo i2cdetect -y 1
  ```
- [ ] Python 라이브러리 설치
  ```bash
  pip install mpu6050-raspberrypi
  ```
- [ ] 센서 테스트 코드 작성
  ```python
  from mpu6050 import mpu6050
  from time import sleep
  
  sensor = mpu6050(0x68)
  
  while True:
      accel_data = sensor.get_accel_data()
      print(f"X: {accel_data['x']}, Y: {accel_data['y']}, Z: {accel_data['z']}")
      sleep(0.5)
  ```

### 버튼 모듈
- [ ] 버튼 모듈 GPIO 연결
  - 플레이어1 버튼 → GPIO17
  - 플레이어2 버튼 → GPIO18
  - 리셋 버튼 → GPIO22
- [ ] 풀업 저항 설정
- [ ] Python 테스트 코드 작성
  ```python
  import RPi.GPIO as GPIO
  import time
  
  GPIO.setmode(GPIO.BCM)
  GPIO.setup(17, GPIO.IN, pull_up_down=GPIO.PUD_UP)
  
  def button_callback(channel):
      print(f"Button {channel} pressed!")
  
  GPIO.add_event_detect(17, GPIO.FALLING, callback=button_callback, bouncetime=300)
  
  try:
      while True:
          time.sleep(0.1)
  except KeyboardInterrupt:
      GPIO.cleanup()
  ```

## 🎮 출력 장치 연결

### LED 또는 디스플레이
- [ ] 디스플레이 선택
  - [ ] 7-세그먼트 디스플레이
  - [ ] OLED 디스플레이
  - [ ] LCD 디스플레이
- [ ] 디스플레이 연결
  - I2C 연결 (OLED/LCD)
  - GPIO 연결 (7-세그먼트)
- [ ] Python 라이브러리 설치
  ```bash
  # OLED 디스플레이 예시
  pip install luma.oled
  ```
- [ ] 디스플레이 테스트 코드 작성
  ```python
  # OLED 디스플레이 예시
  from luma.core.interface.serial import i2c
  from luma.core.render import canvas
  from luma.oled.device import ssd1306
  
  serial = i2c(port=1, address=0x3C)
  device = ssd1306(serial)
  
  with canvas(device) as draw:
      draw.rectangle(device.bounding_box, outline="white", fill="black")
      draw.text((10, 10), "Player 1: 0", fill="white")
      draw.text((10, 30), "Player 2: 0", fill="white")
  ```

## 🔄 소프트웨어 설정

### 파이썬 환경
- [ ] Python 3.8+ 설치 확인
- [ ] 가상 환경 설정
  ```bash
  python -m venv venv
  source venv/bin/activate
  ```
- [ ] 필요한 패키지 설치
  ```bash
  pip install flask flask-cors opencv-python numpy firebase-admin
  ```
- [ ] 시스템 시작 시 자동 실행 설정
  - [ ] systemd 서비스 파일 생성
  ```bash
  sudo nano /etc/systemd/system/pingpong.service
  ```
  ```
  [Unit]
  Description=Pingpong Smart System
  After=network.target
  
  [Service]
  ExecStart=/bin/bash -c 'cd /home/pi/pingpong && source venv/bin/activate && python app.py'
  WorkingDirectory=/home/pi/pingpong
  User=pi
  Group=pi
  Restart=always
  
  [Install]
  WantedBy=multi-user.target
  ```
  - [ ] 서비스 활성화
  ```bash
  sudo systemctl enable pingpong.service
  sudo systemctl start pingpong.service
  ```

### Flask API 설정
- [ ] Flask 앱 작성
  ```python
  from flask import Flask, request, jsonify
  from flask_cors import CORS
  
  app = Flask(__name__)
  CORS(app)
  
  @app.route('/api/health', methods=['GET'])
  def health_check():
      return jsonify({'status': 'ok'})
  
  if __name__ == '__main__':
      app.run(host='0.0.0.0', port=5000)
  ```
- [ ] 센서/카메라 통합 코드 작성
- [ ] Firebase 연동 설정

## 📦 통합 및 테스트

### 하드웨어 통합
- [ ] 모든 센서/디스플레이 연결 확인
- [ ] 케이블 정리 및 고정
- [ ] 케이스 내 배치 최적화
- [ ] 전원 안정성 확인

### 소프트웨어 통합
- [ ] 카메라 + 센서 + Flask 통합 테스트
- [ ] Firebase 연동 테스트
- [ ] Flutter 앱 연동 테스트
- [ ] 시스템 재부팅 후 자동 실행 테스트

### 성능 최적화
- [ ] CPU/메모리 사용량 모니터링
- [ ] 카메라 해상도/프레임 레이트 최적화
- [ ] 센서 샘플링 레이트 최적화
- [ ] 열 관리 확인 (과열 방지)

## 🏓 탁구 테이블 설치

### 물리적 설치
- [ ] 라즈베리파이 및 센서 장착 위치 선정
- [ ] 카메라 마운트 설계 및 제작
  - [ ] 적절한 각도로 테이블 조망
  - [ ] 흔들림 방지 마운트
- [ ] 전원 공급 설계
  - [ ] 안정적인 전원 공급 확보
  - [ ] 케이블 라우팅 및 보호

### 진동 센서 보정
- [ ] 탁구대 진동 패턴 측정
- [ ] 임계값 설정 및 테스트
- [ ] 오탐지 필터링 로직 구현

### 시스템 튜닝
- [ ] 다양한 조명 환경에서 카메라 테스트
- [ ] 다양한 플레이 패턴에서 센서 테스트
- [ ] 최종 사용자 테스트 및 피드백 수집 