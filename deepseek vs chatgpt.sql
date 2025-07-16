select ai_platform,count(ai_platform),query_type from deepseek_vs_chatgpt
group by Query_type,ai_platform;
select sum(active_users) from deepseek_vs_chatgpt;
select * from deepseek_vs_chatgpt;
# Q1-
select ai_platform,sum(active_users) as Total_Active_Users
from deepseek_vs_chatgpt
group by ai_platform
order by Total_Active_Users desc;
# Q2-
select ai_platform,month_num,avg(daily_churn_rate)
from deepseek_vs_chatgpt
group by ai_platform,month_num
order by avg(daily_churn_rate) desc;
#Q3--
select ai_model_version,weekday,avg(daily_churn_rate)
from deepseek_vs_chatgpt
group by ai_model_version,weekday
order by avg(daily_churn_rate) desc;
#Q4--
select ai_platform,avg(daily_churn_rate)
from deepseek_vs_chatgpt
group by ai_platform;
#Q5--
select date,sum(churned_users)
from deepseek_vs_chatgpt
group by date 
order by sum(churned_users) desc limit 3;
#Q6--
select ai_platform,round(avg(retention_rate),2)
from deepseek_vs_chatgpt
group by ai_platform;
#Q7--
select region,max(user_return_frequency)
from deepseek_vs_chatgpt
group by region 
having max(user_return_frequency)>=10
order by max(user_return_frequency) desc ,region;
#Q8--
select Device_Type,max(user_return_frequency),min(user_return_frequency),avg(user_return_frequency)
from deepseek_vs_chatgpt
group by Device_Type
order by avg(user_return_frequency) desc;
#Q9--
select Device_Type,avg(Session_duration_sec)
from deepseek_vs_chatgpt
group by Device_Type
order by avg(Session_duration_sec) desc;
#Q10--
select Language,round(avg(User_Rating),2)
from deepseek_vs_chatgpt
group by Language
order by round(avg(User_Rating),2) desc;
#Q11--
select Device_Type,max(session_duration_sec),max(user_return_frequency)
from deepseek_vs_chatgpt
group by Device_Type
order by Device_type limit 1;
#Q12--
select Query_Type,AI_platform,round(avg(Response_Accuracy),2),round(avg(User_Experience_Score),2), 
dense_rank() over(order by query_type) rn
from deepseek_vs_chatgpt
group by Query_Type,AI_Platform
order by avg(Response_Accuracy) desc,avg(User_Experience_Score) desc;
# 
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

# Q13-- top weekdays with most active users 
select weekday,AI_Platform,Active_users from (select weekday,AI_platform,max(Active_Users) as Active_users,row_number()over(partition by weekday order by max(Active_Users) desc) as rn
from deepseek_vs_chatgpt
group by weekday,AI_Platform
Order by weekday ) ranked 
where rn=1
order by weekday desc limit 3;
#--alternative
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

# Q14--
select query_type,Topic_category,cmi from(select query_type,Topic_category,max(Customer_Support_Interactions) as cmi,row_number()over(partition by query_type order by max(Customer_Support_Interactions)desc) as rn
from deepseek_vs_chatgpt
group by Query_type,Topic_category) as ranked 
where rn<=3
order by Query_Type,cmi desc;

# Q15--

select AI_Platform,Response_Time_Category,count(*) as Category_Count,round(100*count(*)/sum(count(*)) over (partition by AI_platform),2) As Percentage_Distribution
from deepseek_vs_chatgpt
Group By Ai_Platform,Response_Time_Category;

#Q16--correlation between response speed accuracy and 
select 
      round((count(*) * sum(response_speed_sec*user_rating)-sum(response_speed_sec)*sum(user_rating))/
      sqrt((count(*)*sum(response_speed_sec*response_speed_sec)-power(sum(response_speed_sec),2))*(count(*)*sum(user_rating*user_rating)-power(sum(user_rating),2))),2) as pearson_correlation
from deepseek_vs_chatgpt
where response_speed_sec is not null and user_rating is not null;
#--slower responses decrease the rating with slower rate of correlation -0.46

#Q16--
select Input_Text_length,round(avg(Response_Tokens),2)
from deepseek_vs_chatgpt
group by Input_text_length
order by Input_Text_length;

#Q17--
 select AI_Platform,Correction_Needed,round(100*count(*)/sum(count(*))over(partition by AI_Platform),2) as Percentage_Of_Users_Needed_Or_Not
 from deepseek_vs_chatgpt
 group by AI_platform,Correction_Needed;
 
 #Q18--
 
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

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 














