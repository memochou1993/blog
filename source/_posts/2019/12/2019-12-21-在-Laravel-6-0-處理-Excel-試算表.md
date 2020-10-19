---
title: 在 Laravel 6.0 處理 Excel 試算表
permalink: 在-Laravel-6-0-處理-Excel-試算表
date: 2019-12-21 22:17:40
tags: ["程式設計", "PHP", "Laravel", "Excel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 做法

安裝 `maatwebsite/excel` 套件，此套件封裝了 `PHPOffice/PhpSpreadsheet` 套件。

```BASH
composer require maatwebsite/excel
```

建立 `BookingsExport` 匯出類別。

```BASH
php artisan make:export BookingsExport
```

修改 `BookingsExport` 匯出類別。

```PHP
namespace App\Exports;

use App\Repositories\BookingRepository;
use Maatwebsite\Excel\Events\AfterSheet;
use Maatwebsite\Excel\Concerns\Exportable;
use Maatwebsite\Excel\Concerns\WithEvents;
use Maatwebsite\Excel\Events\BeforeExport;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithHeadings;
use PhpOffice\PhpSpreadsheet\Cell\Coordinate;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use App\Http\Requests\BookingRequest as Request;
use PhpOffice\PhpSpreadsheet\Style\NumberFormat;
use Maatwebsite\Excel\Concerns\WithColumnFormatting;
use Maatwebsite\Excel\Concerns\RegistersEventListeners;

class BookingsExport implements
    FromCollection,
    WithHeadings,
    WithMapping,
    WithColumnFormatting,
    ShouldAutoSize,
    WithEvents
{
    use Exportable; // 使得匯出類別可以被依賴注入
    use RegistersEventListeners; // 使得匯出類別可以被註冊事件

    /**
     * @var \App\Http\Requests\BookingRequest
     */
    protected $request;

    /**
     * @var \App\Contracts\BookingRepositoryInterface
     */
    protected $bookingRepo;

    /**
     * @var string
     */
    protected $title = 'Bookings';

    /**
     * @var string
     */
    protected $creator = 'Memo Chou';

    /**
     * @var \Illuminate\Database\Eloquent\Collection
     */
    protected $rows;

    public function __construct(
        Request $request,
        BookingRepository $bookingRepo
    ) {
        $this->request = $request;
        $this->bookingRepo = $bookingRepo;
    }

    /**
     * @return array
     */
    public function registerEvents(): array
    {
        return [
            BeforeExport::class => function (BeforeExport $event) {
                $event->writer
                    ->getProperties()
                    ->setCreator($this->creator) // 設置作者
                    ->setLastModifiedBy($this->creator) // 設置修改作者
                    ->setTitle($this->title); // 設置標題

                $event->writer
                    ->getDefaultStyle()
                    ->getFont()
                    ->setName('Times New Roman') // 設置字型
                    ->setSize(12); // 設置字體大小
            },
            AfterSheet::class => function (AfterSheet $event) {
                $firstColumn = 'A'; // 第一行座標
                $lastColumn = Coordinate::stringFromColumnIndex(count($this->headings())); // 最後行座標
                $firstRow = 1; // 第一列座標
                $lastRow = count($this->rows) + /** title */ 1 + /** header */ 1 + /** empty rows */ 2; // 最後列座標

                // 置中樣式
                $alignCenter = [
                    'alignment' => [
                        'horizontal' => Alignment::HORIZONTAL_CENTER
                    ]
                ];

                // 在第一列之前插入一列
                $event->sheet->insertNewRowBefore($firstRow, 1);

                // 合併儲存格
                $event->sheet->mergeCells(sprintf('%s%d:%s%d', $firstColumn, $firstRow, $lastColumn, $firstRow));

                // 設置儲存格內容
                $event->sheet->setCellValue(sprintf('%s%d', $firstColumn, $firstRow), $this->title);

                // 設置儲存格樣式
                $event->sheet->getStyle(sprintf('%s%d', $firstColumn, $firstRow))->applyFromArray($alignCenter);
            },
        ];
    }

    /**
    * @return array
    */
    public function headings(): array
    {
        // 設置表頭
        return [
            'No.',
            'PNR',
            'Last Name',
            'First Name',
            'Departure City',
            'Arrival City',
            'Currency',
            'Amount',
            'Payment Type',
            'Card Type',
            'Application Type',
            'Transaction Date',
        ];
    }

    /**
    * @return array
    */
    public function map($row): array
    {
        // 修改資料集合
        return [
            [
                $row['number'],
                $row['pnr'],
                $row['last_name'],
                $row['first_name'],
                $row['departure_city'],
                $row['arrival_city'],
                $row['currency'],
                $row['amount'],
                $row['payment_type'],
                $row['card_vendor'],
                $row['application_type'],
                $row['transaction_date'],
            ],
        ];
    }

    /**
    * @return array
    */
    public function columnFormats(): array
    {
        // 設置儲存格格式
        return [
            'H' => NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1,
        ];
    }

    /**
    * @return \Illuminate\Support\Collection
    */
    public function collection()
    {
        // 設置資料集合
        $this->rows = $this->bookingRepo->getAllByRequest($this->request->all())
            ->map(function ($booking, $index) {
                // 設置流水號
                return collect((array) $booking)->prepend($index + 1, 'number');
            });

        return $this->rows;
    }
}
```

依賴注入至指定的控制器。

```PHP
public function export(BookingsExport $bookingsExport)
{
    return $bookingsExport->download('bookings.xlsx');
}
```

## 參考資料

- [Laravel Excel](https://laravel-excel.com/)
- [PhpSpreadsheet](https://phpspreadsheet.readthedocs.io/en/latest/)
