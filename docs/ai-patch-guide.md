# AI Patch Guide

기본 원칙은 `drop -> init -> dummy`입니다.

drop이 너무 느리거나 현재 로컬 데이터를 잠깐 유지해야 할 때만 임시 patch를 만듭니다.

## 요청 예시

```text
postgres/schema.sql에 새 컬럼을 추가했다.
현재 로컬 DB를 drop하지 않고 맞추고 싶다.
필요한 ALTER 문을 tmp/patches/YYYYMMDD-add-column.sql로 만들고 적용해줘.
적용 후 schema.sql도 기준 상태로 유지해줘.
실패하면 drop/init/dummy로 돌아가도 된다.
```

## 규칙

- patch는 편의 기능입니다.
- 기준 파일은 항상 `schema.sql`, `dummy.sql`, `dummy.redis`, `redis/contract.md`입니다.
- patch를 적용했다면 기준 파일도 반드시 같은 의미로 수정합니다.
- 꼬이면 patch를 버리고 `drop -> init -> dummy`로 돌아갑니다.

