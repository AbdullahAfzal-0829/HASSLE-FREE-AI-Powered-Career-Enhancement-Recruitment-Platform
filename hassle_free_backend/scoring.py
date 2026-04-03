import re

def calculate_employability_score(resume_data, interview_data=None):
    """
    Calculates a score from 0-10 based on resume analysis and interview performance.
    
    Factors:
    - Resume Skills (40%): Up to 4.0 points
    - Education/Experience Keywords (20%): Up to 2.0 points
    - Interview Performance (40%): Up to 4.0 points (if available)
    """
    score = 0.0
    
    # 1. Resume Skills (Max 4.0)
    skills = resume_data.get('skills', [])
    num_skills = len(skills)
    skill_score = min(num_skills * 0.4, 4.0) # 10 skills = 4.0 points
    score += skill_score
    
    # 2. Education & Experience Keywords (Max 2.0)
    text = resume_data.get('text', '').lower()
    keywords = ['university', 'bachelor', 'master', 'bs', 'ms', 'experience', 'worked', 'project', 'intern']
    found_keywords = [kw for kw in keywords if kw in text]
    keyword_score = min(len(found_keywords) * 0.3, 2.0)
    score += keyword_score
    
    # 3. Interview Performance (Max 4.0)
    interview_score = 0.0
    if interview_data:
        # Weights for interview metrics
        clarity = interview_data.get('clarity', 0.5)
        confidence = interview_data.get('confidence', 0.5)
        technical = interview_data.get('technical', 0.5)
        communication = interview_data.get('communication', 0.5)
        
        avg_interview = (clarity + confidence + technical + communication) / 4.0
        interview_score = avg_interview * 4.0
    else:
        # Default/Initial score if no interview yet
        interview_score = 1.0 # Base points for participating
        
    score += interview_score
    
    # Adjust for badges
    badges = []
    if score >= 8.5:
        badges.append("Top Skilled")
    if num_skills >= 8:
        badges.append("Technical Specialist")
    if interview_score >= 3.2:
        badges.append("Great Communicator")

    return {
        "overall_score": round(min(score, 10.0), 1),
        "breakdown": {
            "skills": round(skill_score, 1),
            "profile": round(keyword_score, 1),
            "interview": round(interview_score, 1)
        },
        "badges": badges
    }
