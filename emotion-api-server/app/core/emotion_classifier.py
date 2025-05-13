import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from typing import List, Dict
import logging

logger = logging.getLogger(__name__)


class EmotionClassifier:
    def __init__(self):
        self.device = self._get_device()
        self.tokenizer, self.model = self._load_model()
        self.model.eval()  # 추론 모드로 설정
        self.labels = list(self.model.config.id2label.values())

    def _get_device(self):
        if torch.cuda.is_available():
            logger.info(f"Using GPU: {torch.cuda.get_device_name(0)}")
            return torch.device("cuda")
        logger.info("Using CPU")
        return torch.device("cpu")

    def _load_model(self):
        model_name = "searle-j/kote_for_easygoing_people"
        tokenizer = AutoTokenizer.from_pretrained(model_name)
        model = AutoModelForSequenceClassification.from_pretrained(model_name)
        return tokenizer, model.to(self.device)

    async def predict(self, texts: List[str], batch_size: int = 32) -> List[Dict]:
        results = []
        for i in range(0, len(texts), batch_size):
            batch = texts[i:i + batch_size]
            inputs = self.tokenizer(
                batch,
                padding=True,
                truncation=True,
                max_length=512,
                return_tensors="pt"
            ).to(self.device)

            with torch.inference_mode():  # 메모리 사용 최적화
                outputs = self.model(**inputs)

            probs = torch.nn.functional.softmax(outputs.logits, dim=-1)
            # 후처리 로직 추가 (43개 → 7개 감정 그룹핑)

            results.extend(self._postprocess(batch, probs))
        return results

    def _postprocess(self, batch, probs):
        # 43개 감정 → 7개 그룹 매핑 예시
        # 1. 레이블 정의
        labels = list(self.model.config.id2label.values())  # 43개 감정 레이블

        # 2. 감정 그룹핑 딕셔너리
        group_map = {
            "기쁨": ["기쁨", "행복", "환영/호의", "감동/감탄", "기대감", "뿌듯함", "편안/쾌적", "신기함/관심", "아껴주는", "흐뭇함(귀여움/예쁨)", "즐거움/신남",
                   "존경"],
            "슬픔": ["슬픔", "절망", "힘듦/지침", "서러움", "불쌍함/연민", "안타까움/실망", "패배/자기혐오", "부끄러움", "한심함", "지긋지긋"],
            "분노": ["분노", "짜증", "부담/안_내킴", "증오/혐오", "화남/분노", "우쭐댐/무시함", "어이없음", "귀찮음", "불평/불만"],
            "불안": ["불안/걱정", "당황/난처", "경악", "공포/무서움", "의심/불신"],
            "혐오": ["역겨움/징그러움", "증오/혐오"],
            "놀람": ["놀람", "경악"],
            "중립": ["없음", "안심/신뢰", "재미없음", "깨달음", "죄책감", "비장함"]
        }


        def map_to_group(label):
            for group, members in group_map.items():
                if label in members:
                    return group
            return "기타"

        processed_results = []
        for text, prob in zip(batch, probs):
            max_idx = torch.argmax(prob).item()
            main_label = labels[max_idx]
            group = map_to_group(main_label)
            processed_results.append({
                "text": text,
                "original_label": main_label,
                "group": group,
                "confidence": float(prob[max_idx])
            })
        return processed_results
