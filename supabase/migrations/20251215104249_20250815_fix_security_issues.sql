/*
  # Fix Security and Performance Issues

  1. Removed Indexes
    - Remove unused indexes on `content_type`, `status`, `scheduled_date`, and `created_at`
    - These indexes are not being used by queries and consume unnecessary storage

  2. Fixed Function Search Path
    - Modified `update_updated_at_column` function to use immutable search_path
    - Prevents security vulnerabilities from search_path manipulation

  3. Security Improvements
    - Better function stability and security posture
    - Reduced storage and maintenance overhead
*/

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_content_posts_content_type') THEN
    DROP INDEX IF EXISTS public.idx_content_posts_content_type;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_content_posts_status') THEN
    DROP INDEX IF EXISTS public.idx_content_posts_status;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_content_posts_scheduled_date') THEN
    DROP INDEX IF EXISTS public.idx_content_posts_scheduled_date;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_content_posts_created_at') THEN
    DROP INDEX IF EXISTS public.idx_content_posts_created_at;
  END IF;
END $$;

DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER update_content_posts_updated_at
  BEFORE UPDATE ON public.content_posts
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
