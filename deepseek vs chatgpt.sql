#📊 AI Platform Comparative Analysis: DeepSeek vs ChatGPT
# Raw Dataset Overview

select * from deepseek_vs_chatgpt;
# Q1- Top AI Platforms by Total Active Users
select ai_platform,sum(active_users) as Total_Active_Users
from deepseek_vs_chatgpt
group by ai_platform
order by Total_Active_Users desc;
# Q2--Monthly Churn Rate Comparison Across Platforms
select ai_platform,month_num,avg(daily_churn_rate)
from deepseek_vs_chatgpt
group by ai_platform,month_num
order by avg(daily_churn_rate) desc;
#Q3--Average Churn Rate by AI Model and Weekday
select ai_model_version,weekday,avg(daily_churn_rate)
from deepseek_vs_chatgpt
group by ai_model_version,weekday
order by avg(daily_churn_rate) desc;
#Q4--Average Churn Rate per AI Platform
select ai_platform,avg(daily_churn_rate)
from deepseek_vs_chatgpt
group by ai_platform;
#Q5-- Top 3 Dates with Maximum User Churn
select date,sum(churned_users)
from deepseek_vs_chatgpt
group by date 
order by sum(churned_users) desc limit 3;
#Q6--Average Retention Rate by Platform
select ai_platform,round(avg(retention_rate),2)
from deepseek_vs_chatgpt
group by ai_platform;
#Q7--Regions with High Return Frequency (>=10)
select region,max(user_return_frequency)
from deepseek_vs_chatgpt
group by region 
having max(user_return_frequency)>=10
order by max(user_return_frequency) desc ,region;
#Q8--Device-Type Wise Return Frequency Stats
select Device_Type,max(user_return_frequency),min(user_return_frequency),avg(user_return_frequency)
from deepseek_vs_chatgpt
group by Device_Type
order by avg(user_return_frequency) desc;
#Q9--Average Session Duration by Device Type
select Device_Type,avg(Session_duration_sec)
from deepseek_vs_chatgpt
group by Device_Type
order by avg(Session_duration_sec) desc;
#Q10--Language-Wise Average User Rating
select Language,round(avg(User_Rating),2)
from deepseek_vs_chatgpt
group by Language
order by round(avg(User_Rating),2) desc;
#Q11--Devices with Longest Sessions and Highest Return Rate
select Device_Type,max(session_duration_sec),max(user_return_frequency)
from deepseek_vs_chatgpt
group by Device_Type
order by Device_type limit 1;
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
select query_type,Topic_category,cmi from(select query_type,Topic_category,max(Customer_Support_Interactions) as cmi,row_number()over(partition by query_type order by max(Customer_Support_Interactions)desc) as rn
from deepseek_vs_chatgpt
group by Query_type,Topic_category) as ranked 
where rn<=3
order by Query_Type,cmi desc;

# Q15--Distribution of Response Time Categories per Platform

select AI_Platform,Response_Time_Category,count(*) as Category_Count,round(100*count(*)/sum(count(*)) over (partition by AI_platform),2) As Percentage_Distribution
from deepseek_vs_chatgpt
Group By Ai_Platform,Response_Time_Category;

#Q16--Correlation Between Response Speed and User Rating
select 
      round((count(*) * sum(response_speed_sec*user_rating)-sum(response_speed_sec)*sum(user_rating))/
      sqrt((count(*)*sum(response_speed_sec*response_speed_sec)-power(sum(response_speed_sec),2))*(count(*)*sum(user_rating*user_rating)-power(sum(user_rating),2))),2) as pearson_correlation
from deepseek_vs_chatgpt
where response_speed_sec is not null and user_rating is not null;
#--slower responses decrease the rating with slower rate of correlation -0.46

#Q17--Input Text Length vs Average Response Tokens
select Input_Text_length,round(avg(Response_Tokens),2)
from deepseek_vs_chatgpt
group by Input_text_length
order by Input_Text_length;

#Q18--Percentage of Users Needing Correction (per Platform)
 select AI_Platform,Correction_Needed,round(100*count(*)/sum(count(*))over(partition by AI_Platform),2) as Percentage_Of_Users_Needed_Or_Not
 from deepseek_vs_chatgpt
 group by AI_platform,Correction_Needed;
 
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
Having Efficiency="High Accuracy + Low_Correction "

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 














