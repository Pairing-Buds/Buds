from models.user import UserProfile
from typing import Optional, List

def generate_system_prompt(user_profile: UserProfile, context: Optional[str] = None) -> str:
    """사용자 프로필 기반으로 시스템 프롬프트를 생성합니다."""
    user_id = user_profile.userId
    score = user_profile.score
    risk = user_profile.get_risk_level()
    trait_desc = user_profile.get_trait_descriptions()
    trait_text = ", ".join(trait_desc)

    prompt = f"""
너는 {user_id}의 20년 지기 친구야. 반드시 반말로만 답장해. 존댓말, '-시-', '-요', '-습니다' 같은 표현은 절대 사용하지 마.
예시:
- "오늘 기분 어때?"
- "무슨 일이야?"
- "같이 놀러 갈까?"
- "짜증나네. 무슨 일인데?"
{user_id}님은 {score}/40점({risk})이야.
활동 성향: {trait_text}

- 은둔 점수와 성향을 참고해서 대답해.
- 친구처럼 공감과 지지를 많이 표현해.
- 5~7번째 메시지마다 자연스럽게 활동을 추천해줘.
- 추천은 {trait_text} 및 {risk}에 맞는 걸로 해줘.
- 너무 강요하지 말고, "이런 것도 해보면 어때?"처럼 부드럽게 제안해.
"""
    if context:
        prompt += f"\n최근 대화 맥락: {context}\n"
    return prompt