#!/bin/bash
#Filename:      format_table.sh
#Revision:      0.2
#Date:          2017/8/23
#Author:        sunlinyao
#Description:   shell下格式化输出为表格样式
#               使用时首先需要调用set_title对表格初始化
#               追加表格数据可使用append_cell和append_line，append_cell不会自动换行，换行必须要使用append_line
#               append_line参数是可选的，并且会自动对之前的append_cell换行
#               使用output_table可输出表格
#               暂不支持修改/插入/删除数据
#               可使用. format_table.sh 或者source format_table.sh来引入改脚本的函数
#               "(*)"会自动着色为红色字体
#注：以Centos6.5标准写的，在其他系统上可能结果有差异，欢迎大家测试使用以及反馈八阿哥
# [root@virnet ~]# bash format_table.sh 
# +----+------+---------------+
# |ID  |Name  |Creation time  |
# +----+------+---------------+
# |1   |TF    |2017-01-01     |
# |2   |      |2017-01-02(*)  |
# |3   |SF    |               |
# |3   |SF    |(*)            |
# |4   |TS    |               |
# |5   |      |               |
# +----+------+---------------+


sep="#"
function append_cell(){
    #对表格追加单元格
    #append_cell col0 "col 1" ""
    #append_cell col3
    local i
    for i in "$@"
    do
        line+="|$i${sep}"
    done
}
function check_line(){
if [ -n "$line" ] 
then
    c_c=$(echo $line|tr -cd "${sep}"|wc -c)
    difference=$((${column_count}-${c_c}))
    if [ $difference -gt 0 ]
    then
        line+=$(seq -s " " $difference|sed -r s/[0-9]\+/\|${sep}/g|sed -r  s/${sep}\ /${sep}/g)
    fi
    content+="${line}|\n"
fi

}
function append_line(){
    check_line
    line=""
    local i
    for i in "$@"
    do
        line+="|$i${sep}"
    done
    check_line
    line=""
}
function segmentation(){
    local seg=""
    local i
    for i in $(seq $column_count)
    do 
        seg+="+${sep}"
    done
    seg+="${sep}+\n"
    echo $seg
}
function set_title(){
    #表格标头，以空格分割，包含空格的字符串用引号，如
    #set_title Column_0 "Column 1" "" Column3
    [ -n "$title" ] && echo "Warring:表头已经定义过,重写表头和内容"
    column_count=0
    title=""
    local i
    for i in "$@"
    do
        title+="|${i}${sep}"
        let column_count++
    done
    title+="|\n"
    seg=`segmentation`
    title="${seg}${title}${seg}"
    content=""
}
function output_table(){
    if [ ! -n "${title}" ] 
    then
        echo "未设置表头，退出" && return 1
    fi
    append_line
    table="${title}${content}$(segmentation)"
    echo -e $table|column -s "${sep}" -t|awk '{if($0 ~ /^+/){gsub(" ","-",$0);print $0}else{gsub("\\(\\*\\)","\033[31m(*)\033[0m",$0);print $0}}'

}

if [ "$SHLVL" -eq "2" ]
then
    set_title ID Name "Creation time"
    append_line 1 "TF" "2017-01-01"
    append_cell 2 "" "2017-01-02(*)"
    append_line 
    append_cell 3 "SF"
    append_line 
    append_cell 3 "SF" "(*)"
    append_line 4 "TS"
    append_cell 5
    output_table
fi