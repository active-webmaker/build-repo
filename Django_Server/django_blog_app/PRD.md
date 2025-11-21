# Django Blog App PRD

## 1. Overview
Django + CKEditor + Bootstrap5 기반의 소규모 블로그 앱.
목적: K8S/CI/CD/모니터링 테스트용 샘플 웹애플리케이션.

## 2. Goals
회원가입/로그인/로그아웃.
게시글 작성/수정/삭제, 목록/상세 보기.
CKEditor를 이용한 리치 텍스트 편집 + 이미지 업로드.
Bootstrap5 기반 반응형 레이아웃.

## 3. Non-goals
태그/카테고리/검색 기능은 이번 스코프에서 제외.
한국어, 영어 외 다국어(i18n) 미지원.
관리자용 대시보드는 Django admin 사용.

## 4. User Roles & Stories
비회원: 회원가입, 로그인 페이지 접근, 게시글 목록/상세 열람.
회원:
게시글 작성/수정/삭제 (본인 글만).
CKEditor로 이미지/텍스트 작성.
관리자: Django admin 사용.

## 5. Functional Requirements
게시글 모델: 제목, 내용(HTML), 작성자, 작성일, 수정일, 썸네일(optional).
이미지 업로드: /media/ckeditor/ 등 특정 경로로 업로드.
권한 처리: 로그인 사용자만 글을 작성하고 자신가 작성한 글만 수정/삭제 가능.

## 6. Non-functional Requirements
SQLite → 나중에 PostgreSQL 또는 MySQL로 교체 가능하도록 설정 분리.
Dockerfile, docker-compose 혹은 K8S 배포를 염두에 둔 설정 구조 (.env, DEBUG, ALLOWED_HOSTS 등).
기본 로깅 설정 (ERROR 로그 파일 저장 정도).