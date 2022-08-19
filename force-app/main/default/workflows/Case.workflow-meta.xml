<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Escalation_Alert</fullName>
        <description>Escalation Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ISS_Email_Templates/Escalation_Notice</template>
    </alerts>
    <alerts>
        <fullName>Notify_ISS_Internal</fullName>
        <description>Notify ISS Internal</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>iss.internal@astm.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Auto_Response_Templates/Case_Auto_Response_Support</template>
    </alerts>
    <alerts>
        <fullName>ScreenMeet_Replay_Notification_email</fullName>
        <description>ScreenMeet Replay Notification email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ScreenMeet_Replay_Notification_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Lvl3_Cat_Req</fullName>
        <description>Updates Category of Request  to Level 3</description>
        <field>Catagory__c</field>
        <literalValue>Level 3</literalValue>
        <name>Update Lvl3 Cat Req</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Escalation Notice</fullName>
        <actions>
            <name>Escalation_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Level 2</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify ISS Internal</fullName>
        <actions>
            <name>Notify_ISS_Internal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>ISS Internal</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Lvl3 Cat Req</fullName>
        <actions>
            <name>Update_Lvl3_Cat_Req</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3 or 4 or 5 or 6</booleanFilter>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Level 3</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Beverly Benson</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Holly Blain</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Franza Darby</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Crystal Kemp</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Mehul Sheth</value>
        </criteriaItems>
        <description>Update Category of Request value to &quot;Level 3&quot; when case owner is changed to Level 3 or Service Desk Team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
