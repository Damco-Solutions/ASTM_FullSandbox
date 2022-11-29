<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_email_to_Lead_Owner</fullName>
        <description>Send email to Lead Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Lead_rejected_by_Channel_Manager_template</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_Lead_Owner_that_Lead_was_approved</fullName>
        <description>Send email to Lead Owner that Lead was approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Lead_approved_by_Channel_Manager_template</template>
    </alerts>
</Workflow>
