*** Test Cases ***
Test Windows API Response
    ${headers}=    Create Dictionary    Authorization=Basic ${windows_auth_token_pass}    Content-Type=application/json
    Create Session    sessionId    ${windows_base_url}    headers=${headers}    verify=False
    ${data}=    Create Dictionary    serverName=GBW201353385
    
    ${response}=    POST On Session    sessionId    /tid-pa-os-health-check/api/v1/os-health-check-request    json=${data}    expected_status=200
    ${parsed_response}=    To JSON    ${response.content}
    Log To Console    "Parsed response: ${parsed_response}"

    ${uptime}=    Find Uptime In Response    ${parsed_response}
    Run Keyword If    '${uptime}' == 'None'    Fail    "Uptime not found in the response"
    Log To Console    "Uptime: ${uptime}"

*** Keywords ***
Find Uptime In Response
    [Arguments]    ${json_data}
    FOR    ${key}    IN    @{json_data}
        Run Keyword If    '${key}' == 'Uptime'    Return From Keyword    ${json_data['Uptime']}
        Run Keyword If    isinstance(${json_data['${key}']}, dict) or isinstance(${json_data['${key}']}, list)    ${nested_uptime}=    Find Uptime In Response    ${json_data['${key}']}
        Run Keyword If    '${nested_uptime}' != 'None'    Return From Keyword    ${nested_uptime}
    END
    Return From Keyword    None  # If 'Uptime' is not found
