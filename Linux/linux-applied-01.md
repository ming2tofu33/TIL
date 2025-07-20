바탕으로 할 수 있는 조금 더 어렵게 응용하거나 실습하는 노트도 한 개 더 만들어줘 

# 🧪 리눅스 명령어 실전 응용 노트 (중급 실습)

## 🧷 1. 실습 목표

- 파일/폴더 생성 및 구조 구성
- 리디렉션(`>`, `>>`)과 파이프(`|`) 사용
- 파일 내용 검색 및 필터링
- 파일 권한 설정(`chmod`)
- 백그라운드 실행 및 프로세스 관리

---

## 📂 2. 폴더 및 파일 구조 만들기

### 📁 폴더 구조

```
~/linux_project/
│
├── data/
│   ├── sales.txt
│   └── employees.txt
├── logs/
└── scripts/

```

### 🛠 명령어 실습

```bash
cd ~
mkdir -p linux_project/{data,logs,scripts}
cd linux_project/data

# 파일 생성 및 내용 입력
echo -e "홍길동,100\n김철수,200\n이영희,150" > sales.txt
echo -e "1,홍길동,영업\n2,김철수,기획\n3,이영희,개발" > employees.txt

```

---

## 📤 3. 출력 리디렉션 & 파이프

### 🔽 리디렉션 연습

```bash
# 로그 출력 저장
date > ../logs/run.log      # 덮어쓰기
echo "실행 완료" >> ../logs/run.log  # 이어쓰기
```

### 🔄 파이프(|) 연습

```bash
# 직원 파일에서 개발 부서만 보기
cat employees.txt | grep 개발
```

---

## 🔍 4. 데이터 검색 및 필터링

```bash
# sales.txt에서 매출 150 이상 검색
awk -F',' '$2 >= 150' sales.txt

# 직원 중 이름에 '김'이 포함된 사람
grep 김 employees.txt

```

---

## 🔐 5. 파일 권한 설정

```bash
cd ~/linux_project/scripts
touch run.sh

# 실행권한 부여
chmod +x run.sh

# 권한 확인
ls -l run.sh

```

### 📌 참고: chmod 숫자 권한

| 권한 | 의미 |
| --- | --- |
| 7 | 읽기+쓰기+실행 (rwx) |
| 6 | 읽기+쓰기 (rw-) |
| 5 | 읽기+실행 (r-x) |
| 4 | 읽기 (r--) |

예: `chmod 755 run.sh` → 사용자(rwx), 그룹(r-x), 기타(r-x)

---

## ⏱ 6. 프로세스 제어

```bash
# 무한 루프 스크립트 생성
echo -e "#!/bin/bash\nwhile true; do echo Working...; sleep 1; done" > loop.sh
chmod +x loop.sh

# 백그라운드 실행
./loop.sh &

# 실행 중 프로세스 확인
ps aux | grep loop.sh

# 프로세스 종료
kill [PID]   # PID는 위 명령어로 확인

```

---

## 📝 7. 종합 실습 과제

> 아래 작업을 순서대로 수행해보세요:
> 
1. `linux_project` 안에 `backup` 폴더 생성
2. `data/` 폴더 내 `.txt` 파일을 모두 `backup` 폴더로 복사
3. 복사된 파일 중 `sales.txt` 이름을 `sales_backup.txt`로 변경
4. `sales_backup.txt`에서 150 이상 매출 직원만 출력하여 `high_sales.txt`에 저장
5. `high_sales.txt` 파일 권한을 **읽기 전용**으로 설정

---

## ✅ 마무리 체크리스트

- [ ]  `mkdir`, `touch`, `mv`, `cp`, `rm` 명령 사용 숙달
- [ ]  `echo`, `cat`, `grep`, `awk`, `chmod` 실습 완료
- [ ]  `|`, `>`, `>>`, `&`, `ps`, `kill` 활용 가능
- [ ]  실습 결과를 `~/linux_project_report.md`로 요약 작성해보기