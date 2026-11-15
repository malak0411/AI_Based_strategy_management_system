
import logging
import ollama

from app.config import settings

logger = logging.getLogger(__name__)


class OllamaClient:
    def __init__(self):
        self.model = settings.OLLAMA_MODEL
        self.client = ollama.Client(host=settings.OLLAMA_HOST)
        self.is_available = False

        try:
            self.client.list()
            self.is_available = True
            logger.info("Ollama service is available")
        except Exception:
            logger.warning("Ollama service is unavailable")

    def generate(
        self,
        prompt: str,
        system_instruction: str = None
    ) -> str:
        messages = []

        if system_instruction:
            messages.append({
                "role": "system",
                "content": system_instruction
            })

        messages.append({
            "role": "user",
            "content": prompt
        })

        response = self.client.chat(
            model=self.model,
            messages=messages
        )

        return response["message"]["content"]


ollama_client = OllamaClient()

