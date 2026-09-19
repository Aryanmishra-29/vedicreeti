-- Create user_completed_tasks table
CREATE TABLE IF NOT EXISTS public.user_completed_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    task_id TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, task_id)
);

-- Enable RLS
ALTER TABLE public.user_completed_tasks ENABLE ROW LEVEL SECURITY;

-- Create Policies
CREATE POLICY "Users can view their own completed tasks" 
    ON public.user_completed_tasks FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own completed tasks" 
    ON public.user_completed_tasks FOR INSERT 
    WITH CHECK (auth.uid() = user_id);
