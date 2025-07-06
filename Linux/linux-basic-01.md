# 🐧 리눅스(Linux) 명령어 기초 강의 노트

## 📂 1. 경로(Path) 관련 기호

| 기호 | 의미 (한글) | 의미 (영어) |
| --- | --- | --- |
| `.` | 현재 디렉토리 | Current directory |
| `..` | 상위 디렉토리 | Parent directory |
| `~` | 사용자 홈 디렉토리 | Home directory |
| `/` | 최상위(root) 디렉토리 | Root directory |
| `*` | 모든 파일/폴더 (와일드카드) | Wildcard (select all files) |

---

## 🧭 2. 디렉토리 탐색 명령어

| 명령어 | 설명 (한글) | 설명 (영어) | 예시 |
| --- | --- | --- | --- |
| `cd` | 디렉토리 이동 | Change Directory | `cd ~/Downloads` |
| `ls` | 파일/폴더 목록 보기 | List contents | `ls -al` |
| `pwd` | 현재 위치 출력 | Print Working Directory | `pwd` |

---

## 🛠️ 3. 파일 및 디렉토리 조작

| 명령어 | 설명 (한글) | 설명 (영어) | 예시 |
| --- | --- | --- | --- |
| `mkdir` | 새 디렉토리 만들기 | Make Directory | `mkdir project` |
| `touch` | 빈 파일 만들기 | Create an empty file | `touch memo.txt` |
| `cp` | 파일 복사 | Copy file | `cp a.txt b.txt` |
| `mv` | 파일 이동 / 이름 변경 | Move or Rename file | `mv old.txt new.txt` |
| `rm` | 파일 삭제 | Remove file | `rm old.txt` |
| `rm -r` | 폴더/하위까지 삭제 | Remove recursively | `rm -r old_folder` |

---

## 🔁 4. 자주 쓰는 옵션 (Options)

| 옵션 | 의미 (한글) | 의미 (영어) |
| --- | --- | --- |
| `-r` | 재귀적으로 (하위 폴더 포함) | Recursive |
| `-f` | 강제로 실행 (확인 생략) | Force |
| `-a` | 숨김파일 포함 | All files (including hidden) |
| `-l` | 자세히 보기 (권한, 크기 등) | Long format |
| `-i` | 삭제 전 사용자에게 확인 요청 | Interactive mode |

---

## 🧪 5. 실습 예시 (Practice Examples)

### 📁 예시 1: 나만의 작업 폴더 만들기

```bash
cd ~              # 홈 디렉토리 이동 (Change to home)
mkdir linux_lab   # 폴더 생성 (Make directory)
cd linux_lab      # 해당 폴더로 이동 (Change directory)
```

### 📄 예시 2: 파일 생성 및 보기

```bash
touch test.txt                    # 빈 파일 생성 (Create empty file)
echo "Hello Linux" > test.txt     # 텍스트 쓰기 (Write to file)
cat test.txt                      # 내용 출력 (Print file content)
```

### 🗂️ 예시 3: 복사 & 이동

```bash
cp test.txt copy.txt              # 파일 복사 (Copy file)
mkdir backup                      # 폴더 생성 (Make directory)
mv copy.txt backup/               # 파일 이동 (Move to folder)
```

### 🧹 예시 4: 삭제

```bash
rm test.txt                       # 파일 삭제 (Remove file)
rm -r backup                      # 폴더 삭제 (Remove folder recursively)
```

### 📍 예시 5: 경로 연습

```bash
cd ..                     # 상위 폴더로 이동 (Go up one level)
cd /etc                   # 루트 하위 폴더로 이동 (Go to system config)
cd ~/linux_lab            # 홈/하위 폴더로 바로 이동 (Go to linux_lab)
```

---

## 🧠 6. 추가로 알아두면 좋은 명령어

| 명령어 | 설명 (한글) | 설명 (영어) |
| --- | --- | --- |
| `cat` | 파일 내용 출력 | Concatenate and print file |
| `echo` | 텍스트 출력 또는 파일에 쓰기 | Output text or write to file |
| `clear` | 터미널 화면 정리 | Clear terminal screen |
| `history` | 이전 명령어 기록 보기 | View command history |
| `man` | 명령어 설명서 보기 | Manual page for command |
| `head` | 파일 앞부분 출력 | Show first lines of a file |
| `tail` | 파일 뒷부분 출력 | Show last lines of a file |
| `grep` | 특정 단어 포함된 줄 찾기 | Search for pattern in text |

---

## ✅ 7. 학습 팁 (Tips)

- 실습은 항상 `~/연습용폴더`에서 진행 → 시스템 손상 방지
- `man [명령어]`로 명령어 문서 확인 가능 (e.g., `man ls`)
- 실수 방지를 위해 삭제는 `rm -i`로 시작
- `Tab` 키로 **자동완성**, `↑ ↓` 화살표로 **이전 명령** 빠르게 호출 가능