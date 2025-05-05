from pydantic import BaseModel, Field
from typing import Dict, List, Optional


class UserProfile(BaseModel):
    userId: int
    score: int
    lifestyleTraits: Dict[str, int]

    def get_risk_level(self) -> str:
        """점수에 따른 위험도를 반환합니다."""
        if self.score <= 15:
            return "사회적 고립 경향이 낮음"
        elif self.score <= 24:
            return "다소 은둔 성향"
        elif self.score <= 30:
            return "은둔 경향 높음"
        else:
            return "심각한 은둔 위험군"

    def get_trait_descriptions(self) -> List[str]:
        """활동 성향 설명을 반환합니다."""
        trait_desc = []
        traits = self.lifestyleTraits

        if traits.get("openness", 0) >= 4:
            trait_desc.append("새로운 장소 탐험을 좋아함")
        if traits.get("sociability", 0) >= 4:
            trait_desc.append("사람들과 어울리는 걸 좋아함")
        if traits.get("routine", 0) >= 4:
            trait_desc.append("규칙적인 생활을 선호함")
        if traits.get("quietness", 0) >= 4:
            trait_desc.append("조용한 환경을 선호함")
        if traits.get("expression", 0) >= 4:
            trait_desc.append("감정/생각 표현을 좋아함")

        return trait_desc if trait_desc else ["특별한 활동 성향 없음"]