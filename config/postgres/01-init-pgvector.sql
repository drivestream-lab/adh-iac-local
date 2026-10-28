-- Enable pgvector on the default maintenance database (runs on first cluster init only).
CREATE EXTENSION IF NOT EXISTS vector;
