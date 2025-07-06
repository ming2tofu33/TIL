# 🔐 리눅스 파일 권한 및 사용자/그룹 관리

---

## 📁 1. 파일 권한 구조 (Permission)

리눅스 파일은 세 그룹에 대해 권한을 가짐:

```bash
-rwxr-xr--  1 user group 1024 Jan 1 10:00 file.txt

```

| 항목 | 의미 |
| --- | --- |
| `-` | 파일 유형 (`-`: 일반파일, `d`: 디렉토리 등) |
| `r` | 읽기 권한 (read) |
| `w` | 쓰기 권한 (write) |
| `x` | 실행 권한 (execute) |
| `user` | 소유자(owner)의 이름 |
| `group` | 소유 그룹의 이름 |

### 🔍 3자리 권한 구조

| 그룹 | 설명 |
| --- | --- |
| 소유자 | 사용자 (user) 권한 |
| 그룹 | 그룹 (group) 권한 |
| 기타 | 나머지 사용자 (others) 권한 |

예: `rwxr-xr--`

→ 사용자: 읽기/쓰기/실행, 그룹: 읽기/실행, 기타: 읽기

---

## 🔧 2. 권한 확인 및 변경

### 📄 권한 확인

```bash
ls -l 파일명

```

### ✍️ 권한 변경: `chmod` (Change Mode)

```bash
chmod [권한] 파일명

```

### 💡 숫자 권한 표기법

| 권한 | 의미 |
| --- | --- |
| 7 | rwx (읽기+쓰기+실행) |
| 6 | rw- (읽기+쓰기) |
| 5 | r-x (읽기+실행) |
| 4 | r-- (읽기만) |
| 0 | --- (없음) |

예: `chmod 755 script.sh`

→ 사용자 rwx, 그룹 r-x, 기타 r-x

### 🔡 문자 권한 표기법

```bash
chmod u+x 파일명     # 사용자에 실행권한 추가
chmod g-w 파일명     # 그룹에 쓰기 권한 제거
chmod o=r 파일명     # 기타 사용자에 읽기만 허용

```

---

## 🧑‍🤝‍🧑 3. 소유자와 그룹 변경: `chown` & `chgrp`

### 🔁 소유자 변경

```bash
chown 사용자명 파일명

```

예: `chown alice myfile.txt`

### 🔁 그룹 변경

```bash
chgrp 그룹명 파일명

```

예: `chgrp devteam myfile.txt`

---

## 🧪 4. 실습 예시

### 📂 실습 1: 권한 확인 & 변경

```bash
touch test.sh
ls -l test.sh              # -rw-r--r--
chmod 755 test.sh          # 실행 권한 추가
ls -l test.sh              # -rwxr-xr-x

```

### 🧪 실습 2: 사용자에게만 실행 권한

```bash
chmod u+x test.txt         # 사용자에게만 실행 권한 부여

```

---

## 👤 5. 사용자와 그룹 관리

> ⚠️ 대부분 루트 권한 필요
> 

| 명령어 | 설명 (한글) | 설명 (영어) |
| --- | --- | --- |
| `adduser` | 사용자 추가 | Add a user |
| `passwd` | 비밀번호 설정/변경 | Set/change user password |
| `deluser` | 사용자 삭제 | Delete a user |
| `addgroup` | 그룹 추가 | Add a group |
| `usermod` | 사용자 수정 | Modify user account |
| `groups` | 사용자가 속한 그룹 보기 | List groups of a user |

### 🔧 실습 예

```bash
sudo adduser bob
sudo passwd bob
sudo addgroup devs
sudo usermod -aG devs bob

```

---

## 🛡️ 6. 특수 권한 (선택 학습)

| 권한 | 설명 |
| --- | --- |
| `SUID` | 실행 시 파일 소유자 권한으로 동작 (Set UID) |
| `SGID` | 실행 시 그룹 권한 유지 (Set GID) |
| `Sticky` | 파일 삭제 제한 (보통 /tmp 폴더에서 사용) |

### 예시:

```bash
chmod +s 파일명    # SUID
chmod +t 폴더명    # Sticky bit

```

---

## ✅ 요약 정리

| 명령어 | 설명 (한글) | 설명 (영어) |
| --- | --- | --- |
| `ls -l` | 권한 확인 | List files with permissions |
| `chmod` | 권한 설정 | Change file permission |
| `chown` | 소유자 변경 | Change file owner |
| `chgrp` | 그룹 변경 | Change file group |
| `adduser` | 사용자 추가 | Add user |
| `usermod` | 사용자 수정 | Modify user |

---

## 🎯 추천 실습 과제

1. `~/permission_lab` 폴더를 만들고 이동
2. `test.txt` 파일을 만들고 읽기만 가능하게 설정
3. 실행 가능한 `hello.sh` 스크립트 작성
4. 새로운 사용자 `tempuser`를 만들고 비밀번호 설정
5. `tempuser`가 `test.txt`를 삭제할 수 있는지 테스트