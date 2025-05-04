from fastapi import APIRouter, HTTPException
import logging
from models.conversation import MessageRequest, MessageResponse
from core.chatbot import chatbot
from .diary_router import router as diary_router
from .chat_routes import router as chat_router

router = APIRouter()

router.include_router(chat_router)
router.include_router(diary_router)