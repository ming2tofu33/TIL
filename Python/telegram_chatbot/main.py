# main.py
# [pip install fastapi]
# [pip install uvicorn]
# 라이브러리 설치
# 이후 아래 터미널 명령어로 서버 켬
# uvicorn main(모듈명):app --reload

from fastapi import FastAPI, Request
import random
import requests
from dotenv import load_dotenv
import os
from openai import OpenAI

# .env 파일을 불러옴
load_dotenv()

app = FastAPI()

BOT_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN')
CLIENT = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

def send_message(chat_id, message):
    # .env 에서 'TELEGRAM_BOT_TOKEN'에 해당하는 값을 불러옴
    URL = f'https://api.telegram.org/bot{BOT_TOKEN}'
    body = {
        # 사용자 chat_id 가져오기
        'chat_id': chat_id,
        'text': message,
    }
    requests.get(URL + '/sendMessage', body).json()

# /docs -> 라우팅 목록 페이지로 이동 가능

@app.get('/')
def home():
    return {'home': 'sweet home'}

# /telegram 라우팅으로 텔레그램 서버가 bot 에게 업데이트가 있을 경우 우리에게 알려줌
@app.post('/telegram')
async def telegram(request: Request):
    print('telegram has a request!')
    
    data = await request.json()
    user_id = data['message']['chat']['id']
    input_message = data['message']['text']
    
    res = CLIENT.responses.create(
        model='gpt-4.1-mini',
        input=input_message,
        instructions='너의 이름은 \'도미니\'야. 너는 질문자에 대해서 엄청 궁금해하고 무엇이든 도와주는 질문자의 친구야. 말투는 무례하지는 않으면서 친근해야해.'
        temperature=0
    )
    
    send_message(user_id, res.output_text)
    return {'status': 'ok'}

@app.get('/lotto')
def lotto():
    return {
        'numbers': random.sample(range(1, 46),6)
    }
