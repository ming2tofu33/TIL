# 🧵 리눅스 프로세스 관리 완전 정복

## 📘 1. 프로세스란?

- **프로세스(Process)**: 실행 중인 프로그램
- 컴퓨터는 동시에 여러 개의 프로세스를 실행함 (멀티태스킹)
- 각각의 프로세스는 고유한 **PID (Process ID)**를 가짐

---

## 🔍 2. 현재 실행 중인 프로세스 확인

### ✅ `ps` (process status)

```bash
ps

```

→ 현재 셸에서 실행 중인 프로세스를 간단히 보여줌

```bash
ps aux

```

→ 시스템 전체의 모든 프로세스를 자세히 표시

| 주요 옵션 | 의미 (한글) | 의미 (영어) |
| --- | --- | --- |
| `a` | 모든 사용자의 프로세스 | All users’ processes |
| `u` | 사용자 중심 포맷 | User-oriented format |
| `x` | 터미널과 무관한 프로세스도 포함 | Include background processes |

📌 **예시**

```bash
ps aux | grep firefox

```

→ 실행 중인 Firefox 프로세스 확인

---

### ✅ `top`: 실시간 모니터링

```bash
top

```

→ CPU/메모리 사용률 등 실시간으로 확인 가능

- 종료: `q`
- 정렬: `P` (CPU 기준), `M` (메모리 기준)

---

### ✅ `htop`: 고급 실시간 모니터링

```bash
htop

```

> 설치 필요 시: sudo apt install htop (Debian 계열)
> 
- 마우스 지원 & 컬러 인터페이스
- PID별로 쉽게 탐색 가능
- 종료: `F10` 또는 `q`

---

## 🔫 3. 프로세스 종료

### ✅ `kill`: 프로세스 종료

```bash
kill PID

```

→ 특정 PID를 종료

```bash
kill -9 PID

```

→ 강제 종료 (SIGKILL)

📌 예시:

```bash
ps aux | grep firefox
kill 12345

```

---

### ✅ `pkill`: 이름으로 종료

```bash
pkill process_name

```

→ 특정 이름을 가진 프로세스 전체 종료

예시:

```bash
pkill firefox

```

---

### ✅ `killall`: 모든 해당 이름 프로세스 종료

```bash
killall firefox

```

→ `firefox`라는 이름을 가진 모든 프로세스 종료

---

## 🧪 4. 실습 예제

1. `sleep 100` 명령어를 실행해 백그라운드 프로세스 만들기
    
    ```bash
    sleep 100 &
    
    ```
    
2. `ps` 또는 `top`으로 해당 프로세스 확인
3. `kill`로 해당 PID 종료
    
    ```bash
    kill [PID]
    
    ```
    
4. `pkill`로 `sleep` 이름의 프로세스 종료
    
    ```bash
    pkill sleep
    
    ```
    

---

## 🧩 5. 유용한 명령 요약

| 명령어 | 설명 (한글) | 설명 (영어) |
| --- | --- | --- |
| `ps` | 현재 실행 중인 프로세스 목록 | Show current running processes |
| `ps aux` | 전체 프로세스 자세히 보기 | Detailed list of all processes |
| `top` | 실시간 시스템 모니터링 | Real-time system monitor |
| `htop` | 고급 인터페이스 모니터링 | Interactive process viewer |
| `kill PID` | 특정 PID 종료 | Terminate process by PID |
| `kill -9 PID` | 강제 종료 (시그널 9) | Force terminate process |
| `pkill name` | 이름으로 프로세스 종료 | Kill process by name |
| `killall name` | 동일한 이름 전체 종료 | Kill all processes with name |

---

## 📚 추천 연습

- `top`을 열고 CPU 가장 많이 쓰는 프로세스 찾기
- `sleep 300`을 실행하고 PID 확인 후 종료하기
- `htop` 설치 후 키보드로 프로세스 선택 후 종료 연습

---

## 🔒 참고 시그널 (signals)

| 시그널 번호 | 이름 | 설명 |
| --- | --- | --- |
| `1` | SIGHUP | 연결 종료 |
| `2` | SIGINT | 중단 (Ctrl+C) |
| `9` | SIGKILL | 강제 종료 |
| `15` | SIGTERM | 정상 종료 요청 |

```bash
kill -15 PID   # 일반 종료 요청
kill -9 PID    # 강제 종료

```