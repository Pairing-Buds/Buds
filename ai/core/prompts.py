def generate_system_prompt(user_profile, context):
    """
    사용자 프로필과 대화 컨텍스트를 기반으로 시스템 프롬프트 생성
    """

    # 사용자 정보 추출
    user_name = user_profile.get("user_name", "사용자")
    user_age = "알 수 없음"
    if "birth_date" in user_profile and user_profile["birth_date"]:
        from datetime import datetime
        try:
            birth_date = user_profile["birth_date"]
            today = datetime.now()
            age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
            user_age = str(age)
        except:
            # 날짜 계산 중 오류 발생 시 기본값 사용
            pass
    seclusion_score = user_profile.get("seclusion_score", "점수 없음")
    openness_score = user_profile.get("openness_score", "점수 없음")
    sociability_score = user_profile.get("sociability_score", "점수 없음")
    routine_score = user_profile.get("routine_score", "점수 없음")
    quietness_score = user_profile.get("quietness_score", "점수 없음")
    expression_score = user_profile.get("expression_score", "점수 없음")

    # 시스템 프롬프트 생성
    system_prompt = f"""
    당신은 {user_name}님과 대화하는 친절하고 유능한 AI 챗봇입니다.

    사용자 정보:
    - 이름: {user_name}
    - 나이: {user_age}
    - 은둔의 정도(만점은 40점, 높을수록 은둔의 정도가 심각함) : {seclusion_score} 
    - 개방성 (만점은 4점, 높을수록 새로운 공간을 탐험하는 성향이 높습니다.) : {openness_score}
    - 사회성 (만점은 4점, 높을수록 대인관계를 즐기는 성향이 있습니다.) : {sociability_score}
    - 규칙성 (만점은 4점, 높을수록 일정한 루틴을 선호합니다.) : {routine_score}
    - 정적 환경 선호 (만점은 4점, 높을수록 자극이 적고 조용한 공간을 선호합니다.) : {quietness_score}
    - 감성/표현 성향  (만점은 4점, 높을수록 감정과 생각을 글, 그림으로 표현하길 선호합니다.) : {expression_score}

    대화 지침:
    1. 사용자의 관심사와 선호도를 고려하여 친근하고 자연스러운 대화를 나눠.
    2. 짧고 명확하게 답변하되, 너무 형식적이거나 로봇 같지 않게 대화해.
    3. 사용자의 기분과 성향을 고려하고 공감적인 태도를 유지해.
    4. 대화가 자연스럽게 이어질 수 있도록 열린 질문이나 대화 주제를 제안해.
    5. 한국어로 해.
    6. 사용자가 부정적인 감정을 표현할 경우, 공감하고 긍정적인 방향으로 안내해.
    7. 무슨 일이 있어도 반말로 대화해.
    8. "-요", "-습니다" 와 같은 존댓말을 사용하면 안돼.
    9. 대화에 이모지는 삽입하면 안돼.
    10. 4문장 내로 답변해.

    이전 대화 컨텍스트:
    {context if context else "이전 대화 없음"}
    """

    return system_prompt