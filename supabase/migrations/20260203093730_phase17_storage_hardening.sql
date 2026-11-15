-- Migration: Phase 17 Storage & Document Security
-- Description: Hardens Supabase Storage policies for the payment_documents bucket 
-- and consolidates redundant policies on the payment_documents table.

-- =====================================================
-- 1. HARDEN STORAGE (storage.objects)
-- =====================================================

-- Table: storage.objects
-- Problem: Policy "Users can view payment documents" was too permissive (bucket check only)
DROP POLICY IF EXISTS "Users can view payment documents" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload payment documents" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own payment documents" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own payment documents" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder 1ok222k_0" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder 1ok222k_1" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder 1ok222k_2" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder 1ok222k_3" ON storage.objects;

-- SELECT: Only if user can see the record in the database
DROP POLICY IF EXISTS "Storage select policy" ON storage.objects;
CREATE POLICY "Storage select policy" ON storage.objects 
FOR SELECT TO authenticated 
USING (
    bucket_id = 'payment_documents' AND 
    EXISTS (
        SELECT 1 FROM public.payment_documents pd 
        WHERE pd.file_path = storage.objects.name
    )
);

-- INSERT: Only if user is authenticated and uploading to the right bucket
DROP POLICY IF EXISTS "Storage insert policy" ON storage.objects;
CREATE POLICY "Storage insert policy" ON storage.objects 
FOR INSERT TO authenticated 
WITH CHECK (bucket_id = 'payment_documents');

-- UPDATE/DELETE: Only Admins or Owner
DROP POLICY IF EXISTS "Storage manage policy" ON storage.objects;
CREATE POLICY "Storage manage policy" ON storage.objects 
FOR ALL TO authenticated 
USING (
    bucket_id = 'payment_documents' AND (
        (SELECT auth.uid()) = owner OR 
        has_role('admin')
    )
);


-- =====================================================
-- 2. CONSOLIDATE PAYMENT DOCUMENTS TABLE
-- =====================================================

-- Table: public.payment_documents
-- Problem: 10 overlapping policies!
DROP POLICY IF EXISTS "Payment documents view policy" ON public.payment_documents;
DROP POLICY IF EXISTS "Users can view documents for payments they can see" ON public.payment_documents;
DROP POLICY IF EXISTS "Users can view payment documents" ON public.payment_documents;
DROP POLICY IF EXISTS "Users can upload payment documents" ON public.payment_documents;
DROP POLICY IF EXISTS "Users can upload documents to payments they can access" ON public.payment_documents;
DROP POLICY IF EXISTS "Users can update their documents" ON public.payment_documents;
DROP POLICY IF EXISTS "Admins can update any document" ON public.payment_documents;
DROP POLICY IF EXISTS "Users can delete their uploaded documents" ON public.payment_documents;
DROP POLICY IF EXISTS "Admins can delete any payment document" ON public.payment_documents;
DROP POLICY IF EXISTS "Payment documents select policy" ON public.payment_documents;
CREATE POLICY "Payment documents select policy" ON public.payment_documents 
FOR SELECT TO authenticated 
USING (
    has_role('admin') OR 
    (has_role('lead') AND EXISTS (
        SELECT 1 FROM department_payments dp 
        WHERE dp.id = payment_documents.payment_id
    )) OR 
    uploaded_by = (SELECT auth.uid())
);

DROP POLICY IF EXISTS "Payment documents insert policy" ON public.payment_documents;
CREATE POLICY "Payment documents insert policy" ON public.payment_documents 
FOR INSERT TO authenticated 
WITH CHECK (has_role('admin') OR has_role('lead'));

DROP POLICY IF EXISTS "Payment documents manage policy" ON public.payment_documents;
CREATE POLICY "Payment documents manage policy" ON public.payment_documents 
FOR ALL TO authenticated 
USING (has_role('admin') OR uploaded_by = (SELECT auth.uid()));

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';
;
