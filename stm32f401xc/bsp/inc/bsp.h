/**
  ******************************************************************************
  * @file           : bsp.h
  * @brief          : Header for bsp.c file.
  * @author         : GOIC Embedded Systems
  * @date           : Aug 20, 2026
  * @version        : 1.0.0
  * @copyright      : Copyright (c) 2026 GOIC Embedded Systems
  ******************************************************************************
  * @attention
  *
  * MIT License
  *
  * Copyright (c) 2026 GOIC Embedded Systems
  *
  * Permission is hereby granted, free of charge, to any person obtaining a copy
  * of this software and associated documentation files (the "Software"), to deal
  * in the Software without restriction, including without limitation the rights
  * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  * copies of the Software, and to permit persons to whom the Software is
  * furnished to do so, subject to the following conditions:
  *
  * The above copyright notice and this permission notice shall be included in all
  * copies or substantial portions of the Software.
  *
  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  * SOFTWARE.
  ******************************************************************************
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef BSP_INCLUDE_BSP_H_
#define BSP_INCLUDE_BSP_H_

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/**
  * @defgroup bsp_Module bsp Module
  * @brief    Public API for bsp driver.
  * @{
  */

/*******************************************************************************/
/* Includes -------------------------------------------------------------------*/
/*******************************************************************************/

#define __STM32F4_BSP_
#ifdef __STM32F4_BSP_
#include "stm32f4xx.h"	/* Choose the target MCU in this header file*/
#endif

/*******************************************************************************/
/* Exported Types -------------------------------------------------------------*/
/*******************************************************************************/

/*--None*/

/*******************************************************************************/
/* Exported Constants ---------------------------------------------------------*/
/*******************************************************************************/

/*--None*/

/*******************************************************************************/
/* Exported Macros ------------------------------------------------------------*/
/*******************************************************************************/

/*--None*/

/*******************************************************************************/
/* Exported Variables ---------------------------------------------------------*/
/*******************************************************************************/

/*--None*/

/*******************************************************************************/
/* Exported Functions ---------------------------------------------------------*/
/*******************************************************************************/

/*--None*/

/**
  * @}
  */

#ifdef __cplusplus
}
#endif /* extern "C" */

#endif /* BSP_INCLUDE_BSP_H_ */
/* End of File */
