# Microprocessors
Repository for Physics Year 3 microprocessors lab
# PIC18 传感器数据采集系统 — 微处理器实验

大三微处理器实验（Physics Year 3 microprocessors lab）的核心项目。基于 **PIC18F87K22**，通过 SPI 读取 **BMI160 六轴惯性传感器**与 **BMP388 气压/温度传感器**，并将原始测量数据经 UART 实时回传，构成一个最小的嵌入式「传感 + 遥测」链路。

> ⚠️ 本仓库默认分支（`master`）只保留了一个计数器的入门 demo。真正的主体工程在 **`B_sensor` 分支**——下面所有说明均针对 `B_sensor` 分支的内容。
> ⚠️ 本仓库默认分支（`master`）只保留了一个计数器的入门 demo ,两个pdf是论文文件

## 硬件平台

- 微控制器：PIC18F87K22
- 惯性传感器：BMI160（3 轴陀螺仪 + 3 轴加速度计，SPI 接口）
- 气压 / 温度传感器：BMP388（24-bit 压力 + 24-bit 温度，SPI 接口）
- SPI：MSSP1 模块，SDO1 = RC5、SCK1 = RC3、SDI1 = RC4，主模式 Fosc/16
- UART：TX1 = RC6，9600 baud（SPBRG1 = 103）
- 片选：BMI160 CS = RE0，BMP388 CS = RE1

## 功能

- SPI 主模式驱动（`SPI_MasterInit` / `SPI_MasterTransmit`）
- UART 9600 串口输出（字节发送、十六进制打印、原始数据帧发送）
- BMI160：软复位 → 读 CHIP_ID → 陀螺仪配置 → 循环读取陀螺仪寄存器
- BMP388：配置过采样（压力 ×16 / 温度 ×4）、ODR 25 Hz、IIR 滤波 → 读取 24-bit 压力与 24-bit 温度
- 主循环：50 ms 周期读取 BMI160 陀螺仪并经 UART 输出原始数据；气压采集通道已实现并准备接入

## 代码结构

```
main.s              # 主程序（B_sensor 分支）：端口初始化 + SPI/UART/IMU 初始化 + 采集循环
IMUbmi160.s        # BMI160 六轴 IMU 的 SPI 驱动
Barometebmp388.s   # BMP388 气压/温度传感器的 SPI 驱动
SPI.s              # SPI 主模式驱动
UART.s             # UART 驱动（9600）+ 原始数据帧发送
config.s           # PIC18F87K22 配置位（时钟、看门狗、复位电压等）
delay.s            # 毫秒级延时
main_or.s          # 历史版本存档
main_or_or.s       # 历史版本存档
Makefile           # 构建脚本（基于 MPLAB X 工具链）
nbproject/         # MPLAB X IDE 工程配置
.gitignore
```

## 关键实现

### 主采集循环（main.s，B_sensor 分支）

```assembly
        ; SPI / UART / IMU 初始化
        call    SPI_MasterInit
        call    UART_Setup
        call    bmi160_init
        call    bmi160_gyro_config
try:
        movlw   50
        call    delay_ms
        call    bmi160_read_gyro_xyz   ; 读取陀螺仪 X/Y/Z 寄存器
        call    UART_Sendraw_O         ; 经 UART 输出原始数据帧
        bra     try
```

`UART_Sendraw_O` 当前发送 BMI160 陀螺仪 **Z 轴**原始值（高/低字节）；`BMP388` 的压力/温度采集（`bmp388_config` / `bmp388_read_raw_P` / `UART_Sendraw_P`）已在驱动中写好，于主循环里暂以注释形式保留，待与 IMU 通道合并启用。

### BMI160 关键寄存器（IMUbmi160.s）

```assembly
GYRO_Z_L_REG   EQU 0x10     ; 陀螺仪 Z 轴低字节
GYRO_Z_H_REG   EQU 0x11     ; 陀螺仪 Z 轴高字节
CHIP_ID_REG    EQU 0x00     ; 芯片 ID
GYR_CONF_REG   EQU 0x42     ; 陀螺仪带宽/采样率配置
GYR_RANGE_REG  EQU 0x43     ; 陀螺仪量程配置
CMD_REG        EQU 0x7E     ; 命令寄存器（软复位写 0xB6）
```

### BMP388 关键寄存器（Barometebmp388.s）

```assembly
BMP388_CHIP_ID_REG  EQU 0x00
BMP388_OSR_REG      EQU 0x1C     ; 过采样：压力 ×16 / 温度 ×4
BMP388_ODR_REG      EQU 0x1D     ; 输出速率：25 Hz
BMP388_CONFIG_REG   EQU 0x1F     ; IIR 滤波系数
BMP388_PWR_CTRL_REG EQU 0x1B     ; 上电 + 使能压力/温度
BMP388_DATA0_REG    EQU 0x04     ; 压力 XLSB（24-bit 连续寄存器）
```

## 构建与烧录

项目使用 MPLAB X IDE 工具链，`Makefile` 已配置标准构建 / 烧录目标：

```bash
make build      # 编译生成 .hex
make load       # 烧录到目标板（需配置编程器，如 PICkit）
```

## 当前状态与后续

- **当前主线**：BMI160 陀螺仪原始数据经 UART 实时输出
- **已实现待接入**：BMP388 压力 / 温度 24-bit 采集（`bmp388_*` 系列例程完整）
- **后续方向**：引入传感器融合与数值积分，由原始角速度 / 压力估计姿态与相对高度，构成一个轻量的实时稳定 / 高度感知前端

## 关联项目

- 同一实验体系下的 Sim2Real 物理仿真标定研究（接触力学参数辨识）：见 `sim2real-grasp-simulation` 仓库
