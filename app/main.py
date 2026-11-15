from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI()

# v1: 保存先はメモリ内(サーバーを再起動すると消える)
memos: dict[int, str] = {}
next_id = 1


class MemoCreate(BaseModel):
    text: str = Field(min_length=1, max_length=200)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/memos", status_code=201)
def create_memo(memo: MemoCreate):
    global next_id
    memo_id = next_id
    memos[memo_id] = memo.text
    next_id += 1
    return {"id": memo_id, "text": memo.text}


@app.get("/memos")
def list_memos():
    return [{"id": i, "text": t} for i, t in memos.items()]


@app.delete("/memos/{memo_id}", status_code=204)
def delete_memo(memo_id: int):
    if memo_id not in memos:
        raise HTTPException(status_code=404, detail="memo not found")
    del memos[memo_id]