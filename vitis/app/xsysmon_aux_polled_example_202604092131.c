#include "xsysmon.h"
#include "xstatus.h"
#include "xil_printf.h"
#include "sleep.h"   // usleep()

#ifndef SDT
#define SYSMON_DEVICE_ID XPAR_SYSMON_0_DEVICE_ID
#else
#define SYSMON_DEVICE_ID 0
#endif

#define SAMPLE_RATE_HZ 10
#define SAMPLE_PERIOD_US (1000000 / SAMPLE_RATE_HZ)

#define CHANNEL_NAME "AUX0"
#define UNIT_NAME "Volts"
#define COMMENT_STR "SysMon AUX0 Sampling"

#define TOTAL_SAMPLES 100
#define BATCH_SIZE 10   // print every 10 samples

static XSysMon SysMonInst;

/************************** Function Prototypes *****************************/
int SysMonAux0Example(u16 DeviceId);
static int SysMonFractionToInt(float FloatNum);

/****************************************************************************/
int main(void)
{
    int Status;

    xil_printf("#START\r\n");
    xil_printf("#RATE=%d\r\n", SAMPLE_RATE_HZ);
    xil_printf("#PERIOD_US=%d\r\n", SAMPLE_PERIOD_US);
    xil_printf("#CHANNEL=%s\r\n", CHANNEL_NAME);
    xil_printf("#UNIT=%s\r\n", UNIT_NAME);
    xil_printf("#COMMENT=%s\r\n", COMMENT_STR);

    Status = SysMonAux0Example(SYSMON_DEVICE_ID);
    if (Status != XST_SUCCESS) {
        xil_printf("Example Failed\r\n");
        return XST_FAILURE;
    }

    xil_printf("Done\r\n");
    return XST_SUCCESS;
}

/****************************************************************************/
int SysMonAux0Example(u16 DeviceId)
{
    int Status;
    XSysMon_Config *ConfigPtr;
    XSysMon *SysMonInstPtr = &SysMonInst;

    u16 raw;
    float voltage;

    float batch[BATCH_SIZE];
    int batch_index = 0;

    int sample_count = 0;

    /* Initialize */
    ConfigPtr = XSysMon_LookupConfig(DeviceId);
    if (ConfigPtr == NULL)
        return XST_FAILURE;

    XSysMon_CfgInitialize(SysMonInstPtr, ConfigPtr,
                          ConfigPtr->BaseAddress);

    Status = XSysMon_SelfTest(SysMonInstPtr);
    if (Status != XST_SUCCESS)
        return XST_FAILURE;

    /* Disable sequencer */
    XSysMon_SetSequencerMode(SysMonInstPtr, XSM_SEQ_MODE_SAFE);

    /* Only AUX0 */
    XSysMon_SetSeqInputMode(SysMonInstPtr, XSM_SEQ_CH_AUX00);
    XSysMon_SetSeqChEnables(SysMonInstPtr, XSM_SEQ_CH_AUX00);

    /* Optional averaging */
    XSysMon_SetAvg(SysMonInstPtr, XSM_AVG_16_SAMPLES);

    /* Start continuous mode */
    XSysMon_SetSequencerMode(SysMonInstPtr, XSM_SEQ_MODE_CONTINPASS);

    //xil_printf("#START\r\n");

    while (sample_count < TOTAL_SAMPLES) {

        /* Read AUX0 */
        raw = XSysMon_GetAdcData(SysMonInstPtr, XSM_CH_AUX_MIN);
        voltage = XSysMon_RawToVoltage(raw);

        /* Store in batch */
        batch[batch_index++] = voltage;
        sample_count++;

        /* Print batch */
        if (batch_index == BATCH_SIZE) {
            for (int i = 0; i < BATCH_SIZE; i++) {
                xil_printf("%d.%03d",
                    (int)batch[i],
                    SysMonFractionToInt(batch[i]));

                if (i < BATCH_SIZE - 1)
                    xil_printf(",");
            }
            xil_printf("\r\n");
            batch_index = 0;
        }

        /* Wait for next sample (10 Hz) */
        usleep(SAMPLE_PERIOD_US);
    }
    
    xil_printf("#STOP\r\n");

    return XST_SUCCESS;
}

/****************************************************************************/
int SysMonFractionToInt(float FloatNum)
{
    float Temp;

    Temp = (FloatNum < 0) ? -FloatNum : FloatNum;

    return (int)((Temp - (int)Temp) * 1000.0f);
}

