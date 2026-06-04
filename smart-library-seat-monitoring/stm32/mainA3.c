/* USER CODE BEGIN Header */
/**
 ******************************************************************************
 * @file           : main.c
 * @brief          : VL53L0X + Bluetooth USART1 + Debug USART2
 ******************************************************************************
 */
/* USER CODE END Header */

#include "main.h"
#include <stdio.h>
#include <string.h>
#include <stdint.h>

/* Private variables ---------------------------------------------------------*/
UART_HandleTypeDef huart1;   // Bluetooth HC-05 / HC-06
UART_HandleTypeDef huart2;   // TeraTerm USB ST-LINK
I2C_HandleTypeDef hi2c1;     // VL53L0X

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_USART1_UART_Init(void);
static void MX_USART2_UART_Init(void);
static void MX_I2C1_Init(void);
void Error_Handler(void);

/* Funzioni stampa */
static void USB_Print(const char *msg);
static void Serial_Print(const char *msg);

/* Funzioni VL53L0X */
static uint8_t VL53L0X_Init(void);
static uint8_t VL53L0X_ReadRangeSingleMillimeters(uint16_t *range_mm);

/* Funzioni I2C basso livello */
static HAL_StatusTypeDef VL53_Write8(uint8_t reg, uint8_t value);
static HAL_StatusTypeDef VL53_Write16(uint8_t reg, uint16_t value);
static HAL_StatusTypeDef VL53_WriteMulti(uint8_t reg, uint8_t *data, uint8_t count);
static HAL_StatusTypeDef VL53_Read8(uint8_t reg, uint8_t *value);
static HAL_StatusTypeDef VL53_Read16(uint8_t reg, uint16_t *value);
static HAL_StatusTypeDef VL53_ReadMulti(uint8_t reg, uint8_t *data, uint8_t count);
static uint8_t VL53_Read8_Block(uint8_t reg);

/* Funzioni helper VL53L0X */
static uint8_t VL53_GetSpadInfo(uint8_t *count, uint8_t *type_is_aperture);
static uint8_t VL53_PerformSingleRefCalibration(uint8_t vhv_init_byte);

/* Configurazione utente -----------------------------------------------------*/
#define VL53L0X_ADDR        0x52
#define I2C_TIMEOUT_MS      100
#define VL53_TIMEOUT_MS     500

#define POSTO_ID            "A3"
#define SOGLIA_OCCUPATO_MM  900

/* Calibrazione software dello zero.
   Se a distanza zero leggi 18/19/20 mm, metti 20.
   Il programma farà: distanza_calibrata = distanza_letta - 20.
 */
#define OFFSET_ZERO_MM      20

/* Registri VL53L0X ----------------------------------------------------------*/
#define SYSRANGE_START                              0x00
#define SYSTEM_SEQUENCE_CONFIG                      0x01
#define SYSTEM_INTERRUPT_CONFIG_GPIO                0x0A
#define SYSTEM_INTERRUPT_CLEAR                      0x0B
#define RESULT_INTERRUPT_STATUS                     0x13
#define RESULT_RANGE_STATUS                         0x14
#define MSRC_CONFIG_CONTROL                         0x60
#define GLOBAL_CONFIG_REF_EN_START_SELECT           0xB6
#define DYNAMIC_SPAD_NUM_REQUESTED_REF_SPAD         0x4E
#define DYNAMIC_SPAD_REF_EN_START_OFFSET            0x4F
#define GLOBAL_CONFIG_SPAD_ENABLES_REF_0            0xB0
#define VHV_CONFIG_PAD_SCL_SDA__EXTSUP_HV           0x89
#define FINAL_RANGE_CONFIG_MIN_COUNT_RATE_RTN_LIMIT 0x44
#define GPIO_HV_MUX_ACTIVE_HIGH                     0x84

static uint8_t stop_variable = 0;

/* MAIN ----------------------------------------------------------------------*/

int main(void)
{
	HAL_Init();
	SystemClock_Config();

	MX_GPIO_Init();

	MX_USART2_UART_Init();
	USB_Print("\r\nA2 - USART2 USB OK\r\n");

	MX_USART1_UART_Init();
	USB_Print("A3 - USART1 Bluetooth OK\r\n");

	MX_I2C1_Init();
	USB_Print("A3 - I2C1 OK\r\n");

	Serial_Print("\r\n====================================\r\n");
	Serial_Print("TEST VL53L0X + BLUETOOTH\r\n");
	Serial_Print("USART2 = TeraTerm USB\r\n");
	Serial_Print("USART1 = Bluetooth HC-05 / HC-06\r\n");
	Serial_Print("I2C1: PB8=SCL, PB9=SDA\r\n");
	Serial_Print("Calibrazione zero attiva\r\n");
	Serial_Print("====================================\r\n\r\n");

	HAL_Delay(500);

	Serial_Print("Controllo presenza VL53L0X...\r\n");

	if (HAL_I2C_IsDeviceReady(&hi2c1, VL53L0X_ADDR, 5, 200) != HAL_OK)
	{
		Serial_Print("ERRORE: VL53L0X non trovato su I2C.\r\n");
		Serial_Print("Controlla VCC=3.3V, GND, SDA=PB9, SCL=PB8, XSHUT=3.3V se presente.\r\n");

		while (1)
		{
			HAL_Delay(1000);
		}
	}

	Serial_Print("VL53L0X trovato su I2C.\r\n");
	Serial_Print("Inizializzazione sensore...\r\n");

	if (!VL53L0X_Init())
	{
		Serial_Print("ERRORE: inizializzazione VL53L0X fallita.\r\n");

		while (1)
		{
			HAL_Delay(1000);
		}
	}

	Serial_Print("VL53L0X inizializzato correttamente.\r\n");
	Serial_Print("Avvio misure distanza calibrate...\r\n\r\n");

	while (1)
	{
		uint16_t distanza_raw_mm = 0;
		int distanza_calibrata_mm = 0;
		char buffer[160];

		if (VL53L0X_ReadRangeSingleMillimeters(&distanza_raw_mm))
		{
			distanza_calibrata_mm = (int)distanza_raw_mm - OFFSET_ZERO_MM;

			if (distanza_calibrata_mm < 0)
			{
				distanza_calibrata_mm = 0;
			}

			/*
			 * Se il sensore legge valori enormi, tipo 7000/8000 mm,
			 * non è una distanza reale utile: lo trattiamo come fuori range.
			 */
			if (distanza_calibrata_mm > 1500)
			{
				snprintf(buffer, sizeof(buffer),
						"%s - Distanza: fuori range - POSTO LIBERO\r\n",
						POSTO_ID);
			}
			else if (distanza_calibrata_mm <= SOGLIA_OCCUPATO_MM)
			{
				snprintf(buffer, sizeof(buffer),
						"%s - Distanza: %d mm - POSTO OCCUPATO\r\n",
						POSTO_ID,
						distanza_calibrata_mm);
			}
			else
			{
				snprintf(buffer, sizeof(buffer),
						"%s - Distanza: %d mm - POSTO LIBERO\r\n",
						POSTO_ID,
						distanza_calibrata_mm);
			}

			Serial_Print(buffer);
		}
		else
		{
			snprintf(buffer, sizeof(buffer),
					"%s - Misura non valida o fuori range - POSTO LIBERO\r\n",
					POSTO_ID);

			Serial_Print(buffer);
		}

		HAL_Delay(500);
	}
}

/* STAMPA SU TERATERM + BLUETOOTH -------------------------------------------*/

static void USB_Print(const char *msg)
{
	HAL_UART_Transmit(&huart2, (uint8_t *)msg, strlen(msg), 100);
}

static void Serial_Print(const char *msg)
{
	HAL_UART_Transmit(&huart2, (uint8_t *)msg, strlen(msg), 100);
	HAL_UART_Transmit(&huart1, (uint8_t *)msg, strlen(msg), 100);
}

/* I2C LOW LEVEL -------------------------------------------------------------*/

static HAL_StatusTypeDef VL53_Write8(uint8_t reg, uint8_t value)
{
	return HAL_I2C_Mem_Write(&hi2c1,
			VL53L0X_ADDR,
			reg,
			I2C_MEMADD_SIZE_8BIT,
			&value,
			1,
			I2C_TIMEOUT_MS);
}

static HAL_StatusTypeDef VL53_Write16(uint8_t reg, uint16_t value)
{
	uint8_t data[2];

	data[0] = (uint8_t)(value >> 8);
	data[1] = (uint8_t)(value & 0xFF);

	return HAL_I2C_Mem_Write(&hi2c1,
			VL53L0X_ADDR,
			reg,
			I2C_MEMADD_SIZE_8BIT,
			data,
			2,
			I2C_TIMEOUT_MS);
}

static HAL_StatusTypeDef VL53_WriteMulti(uint8_t reg, uint8_t *data, uint8_t count)
{
	return HAL_I2C_Mem_Write(&hi2c1,
			VL53L0X_ADDR,
			reg,
			I2C_MEMADD_SIZE_8BIT,
			data,
			count,
			I2C_TIMEOUT_MS);
}

static HAL_StatusTypeDef VL53_Read8(uint8_t reg, uint8_t *value)
{
	return HAL_I2C_Mem_Read(&hi2c1,
			VL53L0X_ADDR,
			reg,
			I2C_MEMADD_SIZE_8BIT,
			value,
			1,
			I2C_TIMEOUT_MS);
}

static HAL_StatusTypeDef VL53_Read16(uint8_t reg, uint16_t *value)
{
	uint8_t data[2];

	if (HAL_I2C_Mem_Read(&hi2c1,
			VL53L0X_ADDR,
			reg,
			I2C_MEMADD_SIZE_8BIT,
			data,
			2,
			I2C_TIMEOUT_MS) != HAL_OK)
	{
		return HAL_ERROR;
	}

	*value = ((uint16_t)data[0] << 8) | data[1];

	return HAL_OK;
}

static HAL_StatusTypeDef VL53_ReadMulti(uint8_t reg, uint8_t *data, uint8_t count)
{
	return HAL_I2C_Mem_Read(&hi2c1,
			VL53L0X_ADDR,
			reg,
			I2C_MEMADD_SIZE_8BIT,
			data,
			count,
			I2C_TIMEOUT_MS);
}

static uint8_t VL53_Read8_Block(uint8_t reg)
{
	uint8_t value = 0;
	VL53_Read8(reg, &value);
	return value;
}

/* DRIVER VL53L0X ------------------------------------------------------------*/

static uint8_t VL53_GetSpadInfo(uint8_t *count, uint8_t *type_is_aperture)
{
	uint8_t tmp;
	uint32_t start_time;

	VL53_Write8(0x80, 0x01);
	VL53_Write8(0xFF, 0x01);
	VL53_Write8(0x00, 0x00);

	VL53_Write8(0xFF, 0x06);
	VL53_Write8(0x83, VL53_Read8_Block(0x83) | 0x04);
	VL53_Write8(0xFF, 0x07);
	VL53_Write8(0x81, 0x01);

	VL53_Write8(0x80, 0x01);

	VL53_Write8(0x94, 0x6B);
	VL53_Write8(0x83, 0x00);

	start_time = HAL_GetTick();

	while (VL53_Read8_Block(0x83) == 0x00)
	{
		if ((HAL_GetTick() - start_time) > VL53_TIMEOUT_MS)
		{
			return 0;
		}
	}

	VL53_Write8(0x83, 0x01);

	tmp = VL53_Read8_Block(0x92);

	*count = tmp & 0x7F;
	*type_is_aperture = (tmp >> 7) & 0x01;

	VL53_Write8(0x81, 0x00);
	VL53_Write8(0xFF, 0x06);
	VL53_Write8(0x83, VL53_Read8_Block(0x83) & ~0x04);
	VL53_Write8(0xFF, 0x01);
	VL53_Write8(0x00, 0x01);

	VL53_Write8(0xFF, 0x00);
	VL53_Write8(0x80, 0x00);

	return 1;
}

static uint8_t VL53_PerformSingleRefCalibration(uint8_t vhv_init_byte)
{
	uint32_t start_time;

	VL53_Write8(SYSRANGE_START, 0x01 | vhv_init_byte);

	start_time = HAL_GetTick();

	while ((VL53_Read8_Block(RESULT_INTERRUPT_STATUS) & 0x07) == 0)
	{
		if ((HAL_GetTick() - start_time) > VL53_TIMEOUT_MS)
		{
			return 0;
		}
	}

	VL53_Write8(SYSTEM_INTERRUPT_CLEAR, 0x01);
	VL53_Write8(SYSRANGE_START, 0x00);

	return 1;
}

static uint8_t VL53L0X_Init(void)
{
	uint8_t spad_count;
	uint8_t spad_type_is_aperture;
	uint8_t ref_spad_map[6];
	uint8_t first_spad_to_enable;
	uint8_t spads_enabled;
	uint8_t i;

	VL53_Write8(VHV_CONFIG_PAD_SCL_SDA__EXTSUP_HV,
			VL53_Read8_Block(VHV_CONFIG_PAD_SCL_SDA__EXTSUP_HV) | 0x01);

	VL53_Write8(0x88, 0x00);

	VL53_Write8(0x80, 0x01);
	VL53_Write8(0xFF, 0x01);
	VL53_Write8(0x00, 0x00);

	stop_variable = VL53_Read8_Block(0x91);

	VL53_Write8(0x00, 0x01);
	VL53_Write8(0xFF, 0x00);
	VL53_Write8(0x80, 0x00);

	VL53_Write8(MSRC_CONFIG_CONTROL,
			VL53_Read8_Block(MSRC_CONFIG_CONTROL) | 0x12);

	VL53_Write16(FINAL_RANGE_CONFIG_MIN_COUNT_RATE_RTN_LIMIT, 32);

	VL53_Write8(SYSTEM_SEQUENCE_CONFIG, 0xFF);

	if (!VL53_GetSpadInfo(&spad_count, &spad_type_is_aperture))
	{
		return 0;
	}

	if (VL53_ReadMulti(GLOBAL_CONFIG_SPAD_ENABLES_REF_0, ref_spad_map, 6) != HAL_OK)
	{
		return 0;
	}

	VL53_Write8(0xFF, 0x01);
	VL53_Write8(DYNAMIC_SPAD_REF_EN_START_OFFSET, 0x00);
	VL53_Write8(DYNAMIC_SPAD_NUM_REQUESTED_REF_SPAD, 0x2C);
	VL53_Write8(0xFF, 0x00);
	VL53_Write8(GLOBAL_CONFIG_REF_EN_START_SELECT, 0xB4);

	first_spad_to_enable = spad_type_is_aperture ? 12 : 0;
	spads_enabled = 0;

	for (i = 0; i < 48; i++)
	{
		if (i < first_spad_to_enable || spads_enabled == spad_count)
		{
			ref_spad_map[i / 8] &= ~(1 << (i % 8));
		}
		else if ((ref_spad_map[i / 8] >> (i % 8)) & 0x01)
		{
			spads_enabled++;
		}
	}

	if (VL53_WriteMulti(GLOBAL_CONFIG_SPAD_ENABLES_REF_0, ref_spad_map, 6) != HAL_OK)
	{
		return 0;
	}

	/* Default tuning settings */
	VL53_Write8(0xFF, 0x01);
	VL53_Write8(0x00, 0x00);

	VL53_Write8(0xFF, 0x00);
	VL53_Write8(0x09, 0x00);
	VL53_Write8(0x10, 0x00);
	VL53_Write8(0x11, 0x00);

	VL53_Write8(0x24, 0x01);
	VL53_Write8(0x25, 0xFF);
	VL53_Write8(0x75, 0x00);

	VL53_Write8(0xFF, 0x01);
	VL53_Write8(0x4E, 0x2C);
	VL53_Write8(0x48, 0x00);
	VL53_Write8(0x30, 0x20);

	VL53_Write8(0xFF, 0x00);
	VL53_Write8(0x30, 0x09);
	VL53_Write8(0x54, 0x00);
	VL53_Write8(0x31, 0x04);
	VL53_Write8(0x32, 0x03);
	VL53_Write8(0x40, 0x83);
	VL53_Write8(0x46, 0x25);
	VL53_Write8(0x60, 0x00);
	VL53_Write8(0x27, 0x00);
	VL53_Write8(0x50, 0x06);
	VL53_Write8(0x51, 0x00);
	VL53_Write8(0x52, 0x96);
	VL53_Write8(0x56, 0x08);
	VL53_Write8(0x57, 0x30);
	VL53_Write8(0x61, 0x00);
	VL53_Write8(0x62, 0x00);
	VL53_Write8(0x64, 0x00);
	VL53_Write8(0x65, 0x00);
	VL53_Write8(0x66, 0xA0);

	VL53_Write8(0xFF, 0x01);
	VL53_Write8(0x22, 0x32);
	VL53_Write8(0x47, 0x14);
	VL53_Write8(0x49, 0xFF);
	VL53_Write8(0x4A, 0x00);

	VL53_Write8(0xFF, 0x00);
	VL53_Write8(0x7A, 0x0A);
	VL53_Write8(0x7B, 0x00);
	VL53_Write8(0x78, 0x21);

	VL53_Write8(0xFF, 0x01);
	VL53_Write8(0x23, 0x34);
	VL53_Write8(0x42, 0x00);
	VL53_Write8(0x44, 0xFF);
	VL53_Write8(0x45, 0x26);
	VL53_Write8(0x46, 0x05);
	VL53_Write8(0x40, 0x40);
	VL53_Write8(0x0E, 0x06);
	VL53_Write8(0x20, 0x1A);
	VL53_Write8(0x43, 0x40);

	VL53_Write8(0xFF, 0x00);
	VL53_Write8(0x34, 0x03);
	VL53_Write8(0x35, 0x44);

	VL53_Write8(0xFF, 0x01);
	VL53_Write8(0x31, 0x04);
	VL53_Write8(0x4B, 0x09);
	VL53_Write8(0x4C, 0x05);
	VL53_Write8(0x4D, 0x04);

	VL53_Write8(0xFF, 0x00);
	VL53_Write8(0x44, 0x00);
	VL53_Write8(0x45, 0x20);
	VL53_Write8(0x47, 0x08);
	VL53_Write8(0x48, 0x28);
	VL53_Write8(0x67, 0x00);
	VL53_Write8(0x70, 0x04);
	VL53_Write8(0x71, 0x01);
	VL53_Write8(0x72, 0xFE);
	VL53_Write8(0x76, 0x00);
	VL53_Write8(0x77, 0x00);

	VL53_Write8(0xFF, 0x01);
	VL53_Write8(0x0D, 0x01);

	VL53_Write8(0xFF, 0x00);
	VL53_Write8(0x80, 0x01);
	VL53_Write8(0x01, 0xF8);

	VL53_Write8(0xFF, 0x01);
	VL53_Write8(0x8E, 0x01);
	VL53_Write8(0x00, 0x01);
	VL53_Write8(0xFF, 0x00);
	VL53_Write8(0x80, 0x00);

	VL53_Write8(SYSTEM_INTERRUPT_CONFIG_GPIO, 0x04);
	VL53_Write8(GPIO_HV_MUX_ACTIVE_HIGH,
			VL53_Read8_Block(GPIO_HV_MUX_ACTIVE_HIGH) & ~0x10);
	VL53_Write8(SYSTEM_INTERRUPT_CLEAR, 0x01);

	VL53_Write8(SYSTEM_SEQUENCE_CONFIG, 0x01);

	if (!VL53_PerformSingleRefCalibration(0x40))
	{
		return 0;
	}

	VL53_Write8(SYSTEM_SEQUENCE_CONFIG, 0x02);

	if (!VL53_PerformSingleRefCalibration(0x00))
	{
		return 0;
	}

	VL53_Write8(SYSTEM_SEQUENCE_CONFIG, 0xE8);

	return 1;
}

static uint8_t VL53L0X_ReadRangeSingleMillimeters(uint16_t *range_mm)
{
	uint32_t start_time;

	VL53_Write8(0x80, 0x01);
	VL53_Write8(0xFF, 0x01);
	VL53_Write8(0x00, 0x00);
	VL53_Write8(0x91, stop_variable);
	VL53_Write8(0x00, 0x01);
	VL53_Write8(0xFF, 0x00);
	VL53_Write8(0x80, 0x00);

	VL53_Write8(SYSRANGE_START, 0x01);

	start_time = HAL_GetTick();

	while (VL53_Read8_Block(SYSRANGE_START) & 0x01)
	{
		if ((HAL_GetTick() - start_time) > VL53_TIMEOUT_MS)
		{
			return 0;
		}
	}

	start_time = HAL_GetTick();

	while ((VL53_Read8_Block(RESULT_INTERRUPT_STATUS) & 0x07) == 0)
	{
		if ((HAL_GetTick() - start_time) > VL53_TIMEOUT_MS)
		{
			return 0;
		}
	}

	if (VL53_Read16(RESULT_RANGE_STATUS + 10, range_mm) != HAL_OK)
	{
		return 0;
	}

	VL53_Write8(SYSTEM_INTERRUPT_CLEAR, 0x01);

	if (*range_mm == 0 || *range_mm > 8190)
	{
		return 0;
	}

	return 1;
}

/* INIZIALIZZAZIONE PERIFERICHE ---------------------------------------------*/

static void MX_USART1_UART_Init(void)
{
	__HAL_RCC_USART1_CLK_ENABLE();

	huart1.Instance = USART1;
	huart1.Init.BaudRate = 9600;
	huart1.Init.WordLength = UART_WORDLENGTH_8B;
	huart1.Init.StopBits = UART_STOPBITS_1;
	huart1.Init.Parity = UART_PARITY_NONE;
	huart1.Init.Mode = UART_MODE_TX_RX;
	huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
	huart1.Init.OverSampling = UART_OVERSAMPLING_16;

	if (HAL_UART_Init(&huart1) != HAL_OK)
	{
		Error_Handler();
	}
}

static void MX_USART2_UART_Init(void)
{
	__HAL_RCC_USART2_CLK_ENABLE();

	huart2.Instance = USART2;
	huart2.Init.BaudRate = 9600;
	huart2.Init.WordLength = UART_WORDLENGTH_8B;
	huart2.Init.StopBits = UART_STOPBITS_1;
	huart2.Init.Parity = UART_PARITY_NONE;
	huart2.Init.Mode = UART_MODE_TX_RX;
	huart2.Init.HwFlowCtl = UART_HWCONTROL_NONE;
	huart2.Init.OverSampling = UART_OVERSAMPLING_16;

	if (HAL_UART_Init(&huart2) != HAL_OK)
	{
		Error_Handler();
	}
}

static void MX_I2C1_Init(void)
{
	__HAL_RCC_I2C1_CLK_ENABLE();

	hi2c1.Instance = I2C1;
	hi2c1.Init.ClockSpeed = 100000;
	hi2c1.Init.DutyCycle = I2C_DUTYCYCLE_2;
	hi2c1.Init.OwnAddress1 = 0;
	hi2c1.Init.AddressingMode = I2C_ADDRESSINGMODE_7BIT;
	hi2c1.Init.DualAddressMode = I2C_DUALADDRESS_DISABLE;
	hi2c1.Init.OwnAddress2 = 0;
	hi2c1.Init.GeneralCallMode = I2C_GENERALCALL_DISABLE;
	hi2c1.Init.NoStretchMode = I2C_NOSTRETCH_DISABLE;

	if (HAL_I2C_Init(&hi2c1) != HAL_OK)
	{
		Error_Handler();
	}
}

static void MX_GPIO_Init(void)
{
	GPIO_InitTypeDef GPIO_InitStruct = {0};

	__HAL_RCC_GPIOA_CLK_ENABLE();
	__HAL_RCC_GPIOB_CLK_ENABLE();
	__HAL_RCC_GPIOC_CLK_ENABLE();

	/*
	 * USART2:
	 * PA2 = USART2_TX
	 * PA3 = USART2_RX
	 */
	GPIO_InitStruct.Pin = GPIO_PIN_2 | GPIO_PIN_3;
	GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
	GPIO_InitStruct.Pull = GPIO_PULLUP;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
	GPIO_InitStruct.Alternate = GPIO_AF7_USART2;
	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

	/*
	 * USART1:
	 * PA9  = USART1_TX
	 * PA10 = USART1_RX
	 */
	GPIO_InitStruct.Pin = GPIO_PIN_9 | GPIO_PIN_10;
	GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
	GPIO_InitStruct.Pull = GPIO_PULLUP;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
	GPIO_InitStruct.Alternate = GPIO_AF7_USART1;
	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

	/*
	 * I2C1:
	 * PB8 = I2C1_SCL
	 * PB9 = I2C1_SDA
	 */
	GPIO_InitStruct.Pin = GPIO_PIN_8 | GPIO_PIN_9;
	GPIO_InitStruct.Mode = GPIO_MODE_AF_OD;
	GPIO_InitStruct.Pull = GPIO_PULLUP;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
	GPIO_InitStruct.Alternate = GPIO_AF4_I2C1;
	HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
}

/* CLOCK ---------------------------------------------------------------------*/

void SystemClock_Config(void)
{
	RCC_OscInitTypeDef RCC_OscInitStruct = {0};
	RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

	__HAL_RCC_PWR_CLK_ENABLE();
	__HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE2);

	RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
	RCC_OscInitStruct.HSIState = RCC_HSI_ON;
	RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
	RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
	RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
	RCC_OscInitStruct.PLL.PLLM = 16;
	RCC_OscInitStruct.PLL.PLLN = 336;
	RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV4;
	RCC_OscInitStruct.PLL.PLLQ = 7;

	if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
	{
		Error_Handler();
	}

	RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK |
			RCC_CLOCKTYPE_SYSCLK |
			RCC_CLOCKTYPE_PCLK1 |
			RCC_CLOCKTYPE_PCLK2;

	RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
	RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
	RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
	RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

	if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
	{
		Error_Handler();
	}
}

/* ERROR HANDLER -------------------------------------------------------------*/

void Error_Handler(void)
{
	while (1)
	{
		HAL_UART_Transmit(&huart2, (uint8_t *)"A2 - ERRORE INIT\r\n", 18, 100);
		HAL_Delay(1000);
	}
}

#ifdef USE_FULL_ASSERT

void assert_failed(uint8_t *file, uint32_t line)
{
}

#endif
