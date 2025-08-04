#📊 AI Platform Comparative Analysis: DeepSeek vs ChatGPT
# Raw Dataset Overview

select count(*) from deepseek_vs_chatgpt;
# Q1- Top AI Platforms by Total Active Users
select ai_platform,concat(round((sum(active_users)/1000000000),2),'B') as Total_Active_Users
from deepseek_vs_chatgpt
group by ai_platform
order by Total_Active_Users desc;
#-- Deepseek has larger number of active users .
# Q2--Monthly Churn Rate Comparison Across Platforms
SELECT 
  ai_platform, 
  month_num, 
  ROUND(AVG(daily_churn_rate), 2) AS avg_monthly_churn_rate
FROM deepseek_vs_chatgpt
GROUP BY ai_platform, month_num
ORDER BY month_num ;
#--Monthly Churn for each month is more on Chatgpt.
#Q3--Average Churn Rate by AI Model and Weekday
select ai_model_version,weekday,round(avg(daily_churn_rate),2)
from deepseek_vs_chatgpt
group by ai_model_version,weekday
order by weekday asc;
#-- Chatgpt model GPT-4 turbo is having more churn every day .
#Q4--Average Churn Rate per AI Platform
SELECT 
  ai_platform, 
  concat(ROUND(AVG(daily_churn_rate) * 100, 2),'%') AS avg_churn_pct
FROM deepseek_vs_chatgpt
WHERE daily_churn_rate IS NOT NULL AND daily_churn_rate BETWEEN 0 AND 1
GROUP BY ai_platform
ORDER BY avg_churn_pct DESC;
#--Chatgpt has more percentage of churned users.
#Q5-- Top 3 Dates with Maximum User Churn
select date,sum(churned_users) as Churned_Users
from deepseek_vs_chatgpt
group by date 
order by sum(churned_users) desc limit 3;
#Q6--Average Retention Rate by Platform
select ai_platform,round(avg(retention_rate),2)
from deepseek_vs_chatgpt
group by ai_platform;
#--Average retention comes to be same.
#Q7--Regions with High Return Frequency 
SELECT 
  region, 
  ROUND(AVG(user_return_frequency), 2) AS user_return_frequency
FROM deepseek_vs_chatgpt
GROUP BY region
ORDER BY user_return_frequency DESC, region
LIMIT 10;
# france has highest return Frequency
#Q8--Device-Type Wise Return Frequency Stats
select Device_Type,max(user_return_frequency),min(user_return_frequency),avg(user_return_frequency)
from deepseek_vs_chatgpt
group by Device_Type
order by avg(user_return_frequency) desc;
#--Tablets and Laptops have slightly high user return frequency
#Q9--Average Session Duration by Device Type
select Device_Type,avg(Session_duration_sec) as Session_duration_sec
from deepseek_vs_chatgpt
group by Device_Type
order by avg(Session_duration_sec) desc;
#Tablet and mobile have high sessions.
#Q10--Language-Wise Average User Rating
select Language,round(avg(User_Rating),2) as User_rating
from deepseek_vs_chatgpt
group by Language
order by round(avg(User_Rating),2) desc;
#--de and en have the highest rating
#Q11--Devices with Longest Sessions and Highest Return Rate
select Device_Type,Round(avg(session_duration_sec),2) as Session_duration_sec,Round(avg(user_return_frequency),2) as user_return_frequency
from deepseek_vs_chatgpt
group by Device_Type
order by Device_type limit 1;
#--Laptop have the highest session duration which enables it with a high user return frequency
#🤖 Platform Comparison Metrics
#Q12--Best Platform per Query Type Based on Accuracy & UX
SELECT *
FROM (
    SELECT 
        Query_Type,
        AI_Platform,
        ROUND(AVG(Response_Accuracy), 2) AS avg_accuracy,
        ROUND(AVG(User_Experience_Score), 2) AS avg_experience,
        ROW_NUMBER() OVER (
            PARTITION BY Query_Type 
            ORDER BY AVG(Response_Accuracy) DESC, AVG(User_Experience_Score) DESC
        ) AS rn
    FROM deepseek_vs_chatgpt
    GROUP BY Query_Type, AI_Platform
) ranked
WHERE rn = 1
ORDER BY avg_accuracy DESC, avg_experience DESC;
#-- for both query types DeepSeek emerges as the suitable AI_Platform

# Q13-- Top Weekdays with Maximum Users per Platform 
SELECT *
FROM (
    SELECT 
        Weekday,
        AI_Platform,
        MAX(Active_Users) AS max_active_users,
        ROUND(AVG(Daily_Churn_Rate), 3) AS avg_churn,
        ROW_NUMBER() OVER (
            PARTITION BY Weekday 
            ORDER BY MAX(Active_Users) DESC
        ) AS rn
    FROM deepseek_vs_chatgpt
    GROUP BY Weekday, AI_Platform
) ranked
WHERE rn = 1
ORDER BY Weekday DESC
LIMIT 3;

# Q14--Top 3 Topics per Query Type with Highest Customer Support Interactions
select query_type,Topic_category,cmi from(select query_type,Topic_category,round(avg(Customer_Support_Interactions),2) as cmi,row_number()over(partition by query_type order by round(avg(Customer_Support_Interactions),2) desc) as rn
from deepseek_vs_chatgpt
group by Query_type,Topic_category) as ranked 
where rn<=3
order by Query_Type,cmi desc;

# Q15--Distribution of Response Time Categories per Platform

select AI_Platform,Response_Time_Category,count(*) as Category_Count,round(100*count(*)/sum(count(*)) over (partition by AI_platform),2) As Percentage_Distribution
from deepseek_vs_chatgpt
Group By Ai_Platform,Response_Time_Category;
# Deepseek emerges as platform with swift Responses.

#Q16--Correlation Between Response Speed and User Rating
select 
      round((count(*) * sum(response_speed_sec*user_rating)-sum(response_speed_sec)*sum(user_rating))/
      sqrt((count(*)*sum(response_speed_sec*response_speed_sec)-power(sum(response_speed_sec),2))*(count(*)*sum(user_rating*user_rating)-power(sum(user_rating),2))),2) as pearson_correlation
from deepseek_vs_chatgpt
where response_speed_sec is not null and user_rating is not null;
#--slower responses decrease the rating with slower rate of correlation -0.46

#Q17--Input Text Length vs Average Response Tokens
select Input_Text_length,round(avg(Response_Tokens),2) as Size_Of_AI_Reply
from deepseek_vs_chatgpt
group by Input_text_length
order by Size_Of_AI_Reply desc limit 3;
#--shows that small to medium  input letters provide a better size of the reply i.e response tokens 

#Q18--Percentage of Users Needing Correction (per Platform)
 select AI_Platform,Correction_Needed,round(100*count(*)/sum(count(*))over(partition by AI_Platform),2) as Percentage_Of_Users_Needed_Or_Not
 from deepseek_vs_chatgpt
 group by AI_platform,Correction_Needed;
 # the percentage of users requiring correction are same on both the platform.
 
 #Q19--Models with High Accuracy & Minimal Correction Requirement
 
 select AI_model_Version,Correction_needed ,round(Avg(Response_Accuracy),2) as Accuracy,
 case
     when correction_needed=0 and round(Avg(Response_Accuracy),2)>0.5 then "High Accuracy + Low_Correction "
     when correction_needed=0 and round(Avg(Response_Accuracy),2)<0.5 then "Low Accuracy + Low_Correction "
     when correction_needed=1 and round(Avg(Response_Accuracy),2)>0.5 then "High Accuracy + Correction_Required "
     else "Low Accuracy + Correction Required"
end as efficiency
from deepseek_vs_chatgpt
group by AI_model_version,Correction_Needed
Having Efficiency="High Accuracy + Low_Correction ".
# Project Ends 
#-- ABHAY PRATAP SINGH

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 














